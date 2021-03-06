
Note: I suggest opening this up as a markdown document for a more delightful viewing experience.

# Login Instructions

You can login to the below user accounts or sign up as a new user.

Existing patient account: "paul" with password "abc"
Existing physician account: "doc" with password "abc"

# General notes

* I recommend taking a few pictures, drawing on them, and then uploading several pictures with and without tags.
* After exploring the patient side of the application, login as a physician and change your tag to see appropriately fetched content
* View patients that you should be treating in the patients tab
* When signing up for an account, clicking "Done" will return you to the login screen that you should use to login with your newly created user
* If fetching from Parse hangs. I suggest checking internet connectivity or just switching tabs to try fetching again.


# Self-assessment of API usages

Below please see a table for points, notes, and testing. The same table is also reflected at [this link](
goo.gl/bjiR4O)

Point totals to 44 from the following uses of the APIs below.
Please see notes for where I ask for depth points.

| API Description             | Points | Notes                                                                                                                         | How to Test                                                                                   |
|-----------------------------|--------|-------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------|
| UITableView/UITableViewCell | 2      | Swipe gestures to call/email, custom table view cells, leveraging the estimatedHeightForRow delegate method                   | Navigate to patients tap after logging into a physician                                       |
| UINavigationBar/UITabBar    | 2      | Programmtically building the navigation bar (i.e. DrawViewController) and creating bar buttons                                | See navigation bar in DrawViewController                                                      |
| UILabel/TextView/Button     | 2      | For textfield delegate usage, modifying textfield input styles, and button appearances programmatically                       | See textfield behavior in SignUpViewController                                                |
| Parse Integration           | 2      | Third-party integration for advanced querying, login/logout, saving and creating objects - asking for 2 depth points          | Upload images to Parse on the patient end, and query images on the physician end              |
| Autolayout Constraints      | 1      | Used throughout the project                                                                                                   | N/A                                                                                           |
| ImagePicker                 | 1      | Picking from camera roll                                                                                                      | Tap camera icon in top left after logging in as a patient                                     |
| UIGesture                   | 2      | Advanced tracking for drawing on an image, swipe gesture directionality, double tapping to signal drawing is done             | Login to patient, take pictures, click "done", tap on a picture, and draw                     |
| Animations                  | 2      | Flipping textbox on sign up, simultaneous rotation + translation animations on the diagnostic end, multiple fading animations | Sign up and toggle between "patient" and "physician", see swiping animation on diagnostic end |
| CoreMotion                  | 1      | Uses MotionEvents to sense shaking of the camera                                                                              | Shake the phone after taking a picture                                                        |
| VisualEffects               | 1      | Blurring image background when tagging image                                                                                  | Take a few pictures, then note the blurred background when uploading the tag + pictures       |
| AVFoundation                | 2      | NCL: Updates the viewFinder in real time - asking for 2 depth                                                                 | See how viewFinder updates in real time in the camera tab                                     |
| NSDefaultUserSettings       | 1      | Saves query settings on the physician end                                                                                     | Click the "gear" icon after logging in as a doctor                                            |
| Segues                      | 1      | Used throughout along with prepareForSegue                                                                                    | N/A                                                                                           |
| UIScrollView                | 2      | Logic to update the scroll position dynamically based on active TextField                                                     | See the signup view                                                                           |
| UIAlertViewController       | 2      | Adding custom actions and factoring it out into a helper util method                                                          | Try to login or sign up with empty text boxes                                                 |
| NSTimer                     | 1      | Removes the instructions on BalancedCameraView after a brief delay                                                            | See how the instructions to take a picture fade out after a delay                             |
| CoreGraphics                | 2      | To draw on a photo before tagging it                                                                                          | Tap on a picture after clicking "done" and draw on the picture                                |
| CoreLocation                | 2      | CLLocation and CLGeocoder to reverse look up city and address location                                                        | Comment out the specified line in `PatientsViewController` and watch the locations update     |
| UISharedApplication         | 1      | Used to call/email patients                                                                                                   | Swipe left on a patient's row in the patients tab                                             |
| CoreData                    | 2      | Used to store and persist the images and the patient data                                                                     | Notice how patients persist after logging out and closing the app                             |
| PageViewController          | 2      | NCL: Used to swipe through the batch of photos that were taken (i.e. TaggingImagesViewController)                             | Swipe through a batch of photos taken                                                         |
| Delegate/Protocol           | 1      | Used to update the image in TagImageViewController after drawing on it                                                        | Notice how the image updates after you draw on it                                             |
| CoreGraphics                | 2      | Heavy use to draw on the image itself                                                                                         | Draw on an image                                                                              |
| Unwind segues               | 2      | Programmatically created an unwind segue (without using the storyboard) and called it                                         | N/A                                                                                           |
| NSNotification              | 2      | Showing/hiding keyboard based on position of textfields. Complex logic with textfield delegate to scroll properly             | See how sign up page handles textboxes                                                        |
| UICollectionView            | 1      | To view multiple images after selecting a patient                                                                             | Click on a patient's row in a physician's tab of patients                                     |
| NSRequest, NSURLConnection  | 1      | Opted to use NSURLConnection instead of contentsOfUrl that we used in class                                                   | See how the profile picture gets loaded asynchornously by the rows in the patient tab         |
| Threading, dispatch_async   | 1      | Made judicious use of dispatch_async to update any UI                                                                         | N/A                                                                                           |
