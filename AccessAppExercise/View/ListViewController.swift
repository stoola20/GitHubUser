////
//  ListViewController.swift
//  AccessAppExercise
//
//  Created by Jesse Chen on 2024/5/14.
//

import RxDataSources
import RxSwift
import UIKit

class ListViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    private let viewModel: ListViewModel
    private let disposeBag = DisposeBag()
    /// Data source for configuring table view sections and cells.
    private let dataSouce = RxTableViewSectionedReloadDataSource<UserListSection> { _, tableView, indexPath, item in
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UserListCell.self), for: indexPath) as? UserListCell else {
            fatalError("Can not dequeue UserListCell")
        }
        cell.selectionStyle = .none
        cell.layoutCell(with: item)
        return cell
    }

    /// Initializes the view controller with a view model.
    ///
    /// - Parameter viewModel: The view model for managing user data.
    init(viewModel: ListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "ListViewController", bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "GitHub User List"
        bindViewModel()
        setUpTableView()

        viewModel.inputs.viewDidLoad()
    }

    /// Binds the view model outputs to the view controller.
    private func bindViewModel() {
        viewModel.outputs
            .userListRelay
            .asObservable()
            .map { [UserListSection(header: "", items: $0)] }
            .bind(to: tableView.rx.items(dataSource: dataSouce))
            .disposed(by: disposeBag)
    }

    /// Sets up the table view appearance and registers the cell.
    private func setUpTableView() {
        tableView.register(cell: UserListCell.self)
        tableView.separatorStyle = .none
    }
}
