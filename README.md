# PocketHTTP
A lightweight iOS app to let you test your HTTP APIs easily on the go, somewhat like a mobile version of [Postman](https://www.getpostman.com).
## Features
* **Fully customized HTTP request**

![Request](https://github.com/AkikoZ/PocketHTTP/blob/master/screenshots/Request.png)

* **Request bookmarks**

![Bookmarks-History](https://github.com/AkikoZ/PocketHTTP/blob/master/screenshots/Bookmarks-History.png)
![Bookmarks-Favorites](https://github.com/AkikoZ/PocketHTTP/blob/master/screenshots/Bookmarks-Favorites.png)

* **Environment variables**

![Environment Variables](https://github.com/AkikoZ/PocketHTTP/blob/master/screenshots/Environment Variables.png)

* **Comprehensive response viewing**

![Response-Pretty](https://github.com/AkikoZ/PocketHTTP/blob/master/screenshots/Response-Pretty.png)
![Response-Info](https://github.com/AkikoZ/PocketHTTP/blob/master/screenshots/Response-Raw.png)
![Response-Preview](https://github.com/AkikoZ/PocketHTTP/blob/master/screenshots/Response-Preview.png)
![Response-Info](https://github.com/AkikoZ/PocketHTTP/blob/master/screenshots/Response-Info.png)

## Installing
1. Clone the content of **PocketHTTP**
2. Open **PocketHTTP.xcworkspace** in Xcode
3. Open Xcode's **Preferences > Accounts** and add your Apple ID
4. In Xcode's sidebar select **PocketHTTP** and go to **Targets > PocketHTTP > General > Identity** and add a word to the end of the **Bundle Identifier** to make it unique, also select your Apple ID in **Signing > Team**
5. Connect your iPhone or iPad and select it in Xcode's **Product menu > Destination**
6. Press **CMD+R** or **Product > Run** to install PocketHTTP
7. If you install using a free (non-developer) account, make sure to rebuild PocketHTTP every 7 days, otherwise it will quit at launch when your certificate expires

## Open-source libraries used
* [Alamofire](https://github.com/Alamofire/Alamofire)
* [highlight.js](https://github.com/isagalaev/highlight.js)
