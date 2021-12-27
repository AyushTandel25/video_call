package com.example.video_call

import android.opengl.GLSurfaceView
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.View
import android.view.ViewGroup
import androidx.annotation.NonNull
import com.example.basic_video_chat_flutter.VideoFactory
import com.example.basic_video_chat_flutter.VideoPlatformView
import com.opentok.android.*

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** VideoCallPlugin */
class VideoCallPlugin: FlutterPlugin, MethodCallHandler {

  private var session: Session? = null
  private var publisher: Publisher? = null
  private var subscriber: Subscriber? = null

  private var tempPublisherView : View? = null
  private var tempSubscriberView : View? = null

  private var isOriginalPosition = true

  private var flutterEngine : FlutterPlugin.FlutterPluginBinding ?= null

  private lateinit var videoPlatformView: VideoPlatformView

  private val sessionListener: Session.SessionListener = object: Session.SessionListener {
    override fun onConnected(session: Session) {
      // Connected to session
      Log.d("MainActivity", "Connected to session ${session.sessionId}")

      publisher = Publisher.Builder(flutterEngine?.applicationContext).build().apply {
        setPublisherListener(publisherListener)
        renderer?.setStyle(BaseVideoRenderer.STYLE_VIDEO_SCALE, BaseVideoRenderer.STYLE_VIDEO_FILL)

        view.layoutParams = ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT)

        tempPublisherView = view

      }

      if (publisher?.view is GLSurfaceView) {
        (publisher?.view as GLSurfaceView).setZOrderOnTop(true)
      }

      publisher?.publishAudio = true

      videoPlatformView.subscriberContainer.addView(tempPublisherView)
      videoPlatformView.publisherContainer.visibility = View.GONE

      notifyFlutter(SdkState.LOGGED_IN)
      session.publish(publisher)
    }

    override fun onDisconnected(session: Session) {
      notifyFlutter(SdkState.LOGGED_OUT)
    }

    override fun onStreamReceived(session: Session, stream: Stream) {
      Log.d(
        "MainActivity",
        "onStreamReceived: New Stream Received " + stream.streamId + " in session: " + session.sessionId
      )
      if (subscriber == null) {
        subscriber = Subscriber.Builder(flutterEngine?.applicationContext, stream).build().apply {
          renderer?.setStyle(BaseVideoRenderer.STYLE_VIDEO_SCALE, BaseVideoRenderer.STYLE_VIDEO_FILL)
          setSubscriberListener(subscriberListener)
          session.subscribe(this)

          tempSubscriberView = view

          videoPlatformView.subscriberContainer.removeAllViews()
          videoPlatformView.subscriberContainer.addView(tempSubscriberView)
          videoPlatformView.publisherContainer.visibility = View.VISIBLE
          videoPlatformView.publisherContainer.removeAllViews()
          videoPlatformView.publisherContainer.addView(tempPublisherView)

        }

        videoPlatformView.subscriberContainer.setOnClickListener {
          swapViews()
        }

        videoPlatformView.publisherContainer.setOnClickListener {
          swapViews()
        }

        notifyFlutter(SdkState.ON_CALL)

      }

    }

    fun swapViews(){
      if(videoPlatformView.publisherContainer.childCount!=0 && videoPlatformView.subscriberContainer.childCount!=0){
        if(isOriginalPosition){
          videoPlatformView.subscriberContainer.removeAllViews()
          videoPlatformView.subscriberContainer.addView(tempPublisherView)
          videoPlatformView.publisherContainer.removeAllViews()
          videoPlatformView.publisherContainer.addView(tempSubscriberView)
        }
        else{
          videoPlatformView.subscriberContainer.removeAllViews()
          videoPlatformView.subscriberContainer.addView(tempSubscriberView)
          videoPlatformView.publisherContainer.removeAllViews()
          videoPlatformView.publisherContainer.addView(tempPublisherView)
        }
        isOriginalPosition = !isOriginalPosition
      }
    }

    override fun onStreamDropped(session: Session, stream: Stream) {
      Log.d(
        "MainActivity",
        "onStreamDropped: Stream Dropped: " + stream.streamId + " in session: " + session.sessionId
      )

      if (subscriber != null) {
        subscriber = null

        videoPlatformView.subscriberContainer.removeAllViews()
      }
    }

    override fun onError(session: Session, opentokError: OpentokError) {
      Log.d("MainActivity", "Session error: " + opentokError.message)
      notifyFlutter(SdkState.ERROR)
    }
  }

  private val publisherListener: PublisherKit.PublisherListener = object :
    PublisherKit.PublisherListener {
    override fun onStreamCreated(publisherKit: PublisherKit, stream: Stream) {
      Log.d("MainActivity", "onStreamCreated: Publisher Stream Created. Own stream " + stream.streamId)
    }

    override fun onStreamDestroyed(publisherKit: PublisherKit, stream: Stream) {
      Log.d("MainActivity", "onStreamDestroyed: Publisher Stream Destroyed. Own stream " + stream.streamId)
    }

    override fun onError(publisherKit: PublisherKit, opentokError: OpentokError) {
      Log.d("MainActivity", "PublisherKit onError: " + opentokError.message)
      notifyFlutter(SdkState.ERROR)
    }
  }

  var subscriberListener: SubscriberKit.SubscriberListener = object :
    SubscriberKit.SubscriberListener {
    override fun onConnected(subscriberKit: SubscriberKit) {
      Log.d("MainActivity", "onConnected: Subscriber connected. Stream: " + subscriberKit.stream.streamId)
    }

    override fun onDisconnected(subscriberKit: SubscriberKit) {
      Log.d("MainActivity", "onDisconnected: Subscriber disconnected. Stream: " + subscriberKit.stream.streamId)
      notifyFlutter(SdkState.LOGGED_OUT)
    }

    override fun onError(subscriberKit: SubscriberKit, opentokError: OpentokError) {
      Log.d("MainActivity", "SubscriberKit onError: " + opentokError.message)
      notifyFlutter(SdkState.ERROR)
    }
  }



  private fun initSession(apiKey:String, sessionId:String, token:String) {
    session = Session.Builder(flutterEngine?.applicationContext, apiKey, sessionId).build()
    session?.setSessionListener(sessionListener)
    session?.connect(token)
  }

  private fun cancelSession(){
    if(session!=null){
      session?.disconnect()
    }
  }

  private fun swapCamera() {
    publisher?.cycleCamera()
  }

  private fun toggleAudio(publishAudio: Boolean) {
    publisher?.publishAudio = publishAudio
    Log.d("audio","$publishAudio")
  }

  private fun toggleVideo(publishVideo: Boolean) {
    publisher?.publishVideo = publishVideo
  }

  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.example.video_call")

    flutterEngine = flutterPluginBinding

    videoPlatformView = VideoFactory.getViewInstance(flutterPluginBinding.applicationContext)

    flutterPluginBinding
      .platformViewRegistry
      // video-container is a custom platform-view-type
      .registerViewFactory("video-container", VideoFactory())

    channel.setMethodCallHandler(this)

  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  private fun notifyFlutter(state: SdkState) {
    Handler(Looper.getMainLooper()).post {
      MethodChannel(flutterEngine?.binaryMessenger, "com.example.video_call")
        .invokeMethod("updateState", state.toString())
    }
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "initSession" -> {
        val apiKey = requireNotNull(call.argument<String>("apiKey"))
        val sessionId = requireNotNull(call.argument<String>("sessionId"))
        val token = requireNotNull(call.argument<String>("token"))

        notifyFlutter(SdkState.WAIT)
        initSession(apiKey, sessionId, token)
        result.success("")
      }
      "cancelSession" -> {
        cancelSession()
        result.success("")
      }
      "swapCamera" -> {
        swapCamera()
        result.success("")
      }
      "toggleAudio" -> {
        val publishAudio = requireNotNull(call.argument<Boolean>("publishAudio"))
        toggleAudio(publishAudio)
        result.success("")
      }
      "toggleVideo" -> {
        val publishVideo = requireNotNull(call.argument<Boolean>("publishVideo"))
        toggleVideo(publishVideo)
        result.success("")
      }
      else -> {
        result.notImplemented()
      }
    }
  }
}


enum class SdkState {
  LOGGED_OUT,
  LOGGED_IN,
  WAIT,
  ERROR,
  ON_CALL
}