# Fastlane Documentation

## Getting Started

Install fastlane using:
```bash
gem install fastlane
```

Or use Bundler by adding this to your Gemfile:
```ruby
gem "fastlane"
```

## iOS

### Setup

1. Update the `Appfile` with your Apple ID and team information
2. Run `fastlane ios setup_signing` to configure code signing with match

### Available lanes

#### Beta
Deploy a new beta build to TestFlight:
```bash
fastlane ios beta
```

#### Release
Push a new release to the App Store:
```bash
fastlane ios release
```

#### Deploy
Complete deployment including certificate matching and TestFlight upload:
```bash
fastlane ios deploy
```

## Android

### Setup

1. Setup Google Play Console API access
2. Download the service account JSON key
3. Place it in `fastlane/google-play-key.json`

### Available lanes

#### Build
Build Android App Bundle:
```bash
fastlane android build
```

#### Beta
Deploy to Play Store Beta track:
```bash
fastlane android beta
```

#### Deploy
Deploy to Play Store Internal track:
```bash
fastlane android deploy
```

## Environment Variables

Create a `.env` file in the fastlane directory with:
```
APPLE_ID=your-apple-id@example.com
FASTLANE_TEAM_ID=your-team-id
ITC_TEAM_ID=your-itc-team-id
FASTLANE_PASSWORD=your-apple-password
```

## Troubleshooting

If you encounter any issues:
1. Check your Apple Developer account credentials
2. Verify your bundle identifier matches
3. Ensure certificates and provisioning profiles are up to date
4. Run `fastlane docs` for detailed documentation

For more information about fastlane:
- [fastlane documentation](https://docs.fastlane.tools)
- [fastlane GitHub](https://github.com/fastlane/fastlane)


