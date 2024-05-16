# AccessAppExercise
An app showing GitHub user list and user detail.

## Feature
- Display Github user list by table view, showing avatar, login name and STAFF badge.

- Enable pagination by parsing next link in response header, and trigger load more in `UITableViewDelegate` `willDisplayCell` method.

- Display detailed user page by navigation controller.

- Custom UI component for STAFF badge.

## Architecture
MVVM + RxSwift

### HTTP Request
- `RequestProtocol` defines default implementation for sending a network request.

- `UserInteractor` is responsible for fetching user data from the GitHub API, and return Observable type for ViewModel.

- `GitHubAPI` use enum and its associate type to construct HTTP method, URL path, headers and parameters for each API case.

### Model
- Structure `GitHubUser` represents a GitHub user in [List users API](https://docs.github.com/en/rest/users/users?apiVersion=2022-11-28#list-users).

- Structure `DetailUser` represents a detailed user information in [Get a user API](https://docs.github.com/en/rest/users/users?apiVersion=2022-11-28#get-a-user).

### View
- `ListViewController` use UITableView to display user list.

- `DetailViewController` consists of UILabel, UIImageView, UIStackView, displaying detailed information of user.

- `BadgeView` is a custom UI component written in programming UI. Seperating this view from UITableViewCell or UIViewController enhances reusability.

- Use auto layout and XIB files to set UI constraints, which is beneficial for understanding the layout of the interface.

-  Other UI settings, like font and text color, are written in code, providing a better way to rebranding or debug.

### ViewModel
- Each view model has Inputs and Outputs type.
    ```Swift
    protocol ListUserViewModelType {
        var inputs: ListUserViewModelInputs { get }
        var outputs: ListUserViewModelOutputs { get }
    }
    ```

- View model is responsible for translate inputs from view controller into outputs as observable.
    ```Swift
    /// Inputs for the `ListUserViewModel`.
    protocol ListUserViewModelInputs {
        /// Called when the view controller is loaded.
        func viewDidLoad()
        /// Called when more users need to be loaded.
        func loadMore()
    }
    ```

    ```Swift
    /// Outputs for the `ListUserViewModel`.
    protocol ListUserViewModelOutputs {
        /// A relay for the list of GitHub users.
        var userListRelay: BehaviorRelay<[GitHubUser]> { get }
        /// A relay for errorMessage.
        var errorRelay: PublishRelay<String> { get }
    }
    ```

- Each view model has interactor(s) to perform HTTP request. The interactor defined by protocol is injected when initiation. In this way, we can use mock interactor in unit test. 
    ```Swift
    init(interactor: UserInteractorProtocol) {
        self.interactor = interactor
    }
    ```

### Data Flow
Client (Mobile) &rarr; view &rarr; view model inputs &rarr; trigger interactor method &rarr; call GitHub REST API &rarr; response parsed to custom model &rarr; view model outputs &rarr; update UI

### Unit Tests
These tests cover various aspects of the application, including extensions and view model functionality.

- `ListViewModelTest.swift` validates ListViewModel's behavior when fetching user list and loading more users from the GitHub API. It also tests the extraction of next link from API response headers.

- `DetailViewModelTest.swift` validates DetailViewModel's behavior when retrieving and handling user details from the GitHub API.

- `StringExtensionTests.swift` verifies the functionality of the String extension used to extract the next link from a GitHub API link header.

- `GitHubAPITest.swift` verifies that the endpoint paths and parameters for fetching user lists and user details are correctly set.

## Library
- [RxSwfit](https://github.com/ReactiveX/RxSwift) for data flow and data binding.

- [RxDataSources](https://github.com/RxSwiftCommunity/RxDataSources) as table view data source.

- [RxAlamofire](https://github.com/RxSwiftCommunity/RxAlamofire) as HTTP networking library.

- [Kingfisher](https://github.com/onevcat/Kingfisher) for downloading and caching images from the web.

## License
This project is licensed under the terms of the MIT license.

See the [LICENSE](https://github.com/stoola20/GitHubUser/blob/feature/list-user/LICENSE) file for more info.
