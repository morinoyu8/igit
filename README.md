# iGit

The iOS app to show Git graph

<img style="width: 20%" src="https://github.com/morinoyu8/igit/assets/93431241/ce18ae07-c979-4443-aafe-326aa3c4e293">

<image style="width: 30%" src="https://github.com/morinoyu8/igit/assets/93431241/b7f0722d-6b10-4966-9c8f-a99732c31f60"></image>

## Build

1. Clone iGit.

2. Add [SwiftGit2](https://github.com/SwiftGit2/SwiftGit2) to iGit.
  
    If you fail to add [SwiftGit2/SwiftGit2](https://github.com/SwiftGit2/SwiftGit2), try adding [morinoyu8/SwiftGit2](https://github.com/morinoyu8/SwiftGit2). Add `github "morinoyu8/SwiftGit2"` to your `Cartfile` and run `carthage update --platform iOS`

    (It worked in my environment😇)

3. Create `iGit.xcconfig` in the app folder with the following contents.

    ```
    // app/iGit.xcconfig
    PRODUCT_BUNDLE_IDENTIFIER = // Bundle identifier
    DEVELOPMENT_TEAM = // Your development team ID
    ``` 

    Change `PRODUCT_BUNDLE_IDENTIFIER` to something unique, and change `DEVELOPMENT_TEAM` to your development team ID.

4. Open the project in Xcode, and click run.