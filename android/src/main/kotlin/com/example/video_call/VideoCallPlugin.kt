package com.example.video_call

import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.View
import android.view.ViewGroup
import androidx.annotation.NonNull
import com.example.basic_video_chat_flutter.OpentokVideoFactory
import com.example.basic_video_chat_flutter.OpentokVideoPlatformView
import com.opentok.android.*
import io.flutter.embedding.engine.FlutterEngine

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

  private var flutterEngine : FlutterPlugin.FlutterPluginBinding ?= null

  private lateinit var opentokVideoPlatformView: OpentokVideoPlatformView

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

      opentokVideoPlatformView.subscriberContainer.addView(tempPublisherView)
      opentokVideoPlatformView.publisherContainer.visibility = View.GONE

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

          opentokVideoPlatformView.subscriberContainer.removeAllViews()
          opentokVideoPlatformView.subscriberContainer.addView(view)
          opentokVideoPlatformView.publisherContainer.visibility = View.VISIBLE
          opentokVideoPlatformView.publisherContainer.removeAllViews()
          opentokVideoPlatformView.publisherContainer.addView(tempPublisherView)

        }

        notifyFlutter(SdkState.ON_CALL)
      }
    }

    override fun onStreamDropped(session: Session, stream: Stream) {
      Log.d(
        "MainActivity",
        "onStreamDropped: Stream Dropped: " + stream.streamId + " in session: " + session.sessionId
      )

      if (subscriber != null) {
        subscriber = null

        opentokVideoPlatformView.subscriberContainer.removeAllViews()
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
  }

  private fun toggleVideo(publishVideo: Boolean) {
    publisher?.publishVideo = publishVideo
  }

  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.example.video_call")

    flutterEngine = flutterPluginBinding

    opentokVideoPlatformView = OpentokVideoFactory.getViewInstance(flutterPluginBinding.applicationContext)

    flutterPluginBinding
      .platformViewRegistry
      // opentok-video-container is a custom platform-view-type
      .registerViewFactory("opentok-video-container", OpentokVideoFactory())

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