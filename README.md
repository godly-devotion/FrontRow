<p align="center">
<img height="256" src="https://github.com/godly-devotion/FrontRow/raw/main/Front Row/Assets.xcassets/AppIcon.appiconset/AppIcon.png" />
</p>

<h1 align="center">Front Row</h1>

<p align="center">Playback HDR Video &amp; Spatial Audio Natively</p>

![Screenshot](.github/images/screenshot.png)

## Compatibility

- Spatial Audio compatible headphones (see [compatible devices](https://support.apple.com/en-us/102469))
- Apple Silicon (M1 and later)
- macOS Sonoma 14.2 and later
- Xcode 15.2 (to build)

## Frequently Asked Questions

### What about just using QuickTime Player?

Sure, that works too. But I didn't like QuickTime Player's keyboard shortcuts nor its large on screen controls which blocks the video and subtitles.

### Where is feature XYZ?

I created Front Row to play those rare video files that are in HDR and/or multichannel with Spatial Audio. For everything else, I use IINA like you.

### Help! My video file is in MKV and doesn't open with Front Row

As Front Row is based on AVKit (which is what QuickTime Player uses), it can't directly open MKV files. However MKV is a container format and it usually contains Apple supported streams such as MPEG-4 video with AAC audio. If so, you can remux the file into an MP4 file using `ffmpeg`.

```
ffmpeg -i ./input.mkv -map 0 -c copy -tag:v hvc1 ./output.mp4
```

Note:
- Add `-c:s mov_text` after `-c copy` if there are built in subtitles
- Use `-tag:v hvc1` for video streams encoded in H265. Use `-tag:v avc1` instead for H264

### I followed the steps above but don't hear any audio

The audio stream is in a codec that is not natively supported by Apple. You'll need to transcode the audio stream into a supported format.

```
ffmpeg -i ./input.mkv -map 0 -c copy -c:a aac_at -b:a 448k -tag:v hvc1 ./output.mp4
```

Note:
- Add `-c:s mov_text` after `-c copy` if there are built in subtitles
- Use `-tag:v hvc1` for video streams encoded in H265. Use `-tag:v avc1` instead for H264

### I don't hear Spatial Audio with my AirPods Pro

First, make sure that the audio track contains more than 2 channels. Also, make sure to turn on Spatial Audio under the audio menu bar while the video is playing.
