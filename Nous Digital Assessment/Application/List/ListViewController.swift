//
//  ListViewController.swift
//  Nous Digital Assessment
//
//  Created by worker on 15/12/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import UIKit
import MessageUI

import Strongify
import RxSwift
import RxCocoa
import RxDataSources
import RxSwiftExt
import RxOptional

final class ListViewController: UIViewController {
    
    typealias ViewModelType = ListViewModel
    
    private static let cellIdentifier: String = "ListCellIdentifier"
    
    let viewModel: ViewModelType
    var disposeBag = DisposeBag()
    
    private lazy var tableView: UITableView = self.createTableView()
    private lazy var searchBar: UISearchBar = self.createSearchBar()
    private lazy var pullToRefresh: UIRefreshControl = self.createPullToRefresh()
    
    init(viewModel: ViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.disposeBag = DisposeBag()
        
        self.setupUI()
        self.setupAutoLayout()
        
        self.rx.viewWillAppearObservable
            .take(1)
            .map({ (_) -> Void in
                return
            })
            .bind(to: self.viewModel.fetchAction)
            .disposed(by: self.disposeBag)
        
        self.pullToRefresh.rx.controlEvent(.valueChanged)
            .bind(to: self.viewModel.fetchAction)
            .disposed(by: self.disposeBag)
        
        self.searchBar.rx.text
            .debounce(.milliseconds(250),
                      scheduler: MainScheduler.instance)
            .filterNil()
            .distinctUntilChanged()
            .bind(to: self.viewModel.searchTerm)
            .disposed(by: self.disposeBag)
        
        let searchBarResignFirstResponder = strongify(weak: self,
                                                      closure: { (self) in
                                                        self.searchBar.resignFirstResponder()
        })
        self.searchBar.rx.cancelButtonClicked
            .subscribe(onNext: searchBarResignFirstResponder)
            .disposed(by: self.disposeBag)
        self.searchBar.rx.searchButtonClicked
            .subscribe(onNext: searchBarResignFirstResponder)
            .disposed(by: self.disposeBag)
        
        self.viewModel.data
            .subscribe()
            .disposed(by: self.disposeBag)
        
        let dataSource = RxTableViewSectionedAnimatedDataSource<ListSection>(configureCell: { [unowned self] (dataSource, tableView, indexPath, item) -> UITableViewCell in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: type(of: self).cellIdentifier,
                                                           for: indexPath) as? ListCell
                else {
                fatalError("Couldn't create custom cell")
            }
            cell.configure(with: item)
            return cell
        })
        
        let data = self.viewModel.data.share(replay: 1, scope: .forever)
        data
            .map({ (data) -> [ListSection] in
                return [ListSection(items: data)]
            })
            .bind(to: self.tableView.rx.items(dataSource: dataSource))
            .disposed(by: self.disposeBag)
        if let backgroundView = self.tableView.backgroundView {
            data
                .map({ (data) -> CGFloat in
                    return data.isEmpty ? 1.0 : 0.0
                })
                .distinctUntilChanged()
                .bind(to: backgroundView.rx.alpha)
                .disposed(by: self.disposeBag)
        }
        data
            .filterEmpty()
            .delay(.seconds(0), scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: strongify(weak: self, closure: { (self, _) in
                self.tableView.reloadData()
            }))
            .disposed(by: self.disposeBag)
        
        self.viewModel.error
            .subscribe(onNext: strongify(weak: self, closure: { (self, error) in
                self.showAlert(with: "Error", message: error.localizedDescription)
            }))
            .disposed(by: self.disposeBag)
        
        self.viewModel.isLoading
            .bind(to: self.pullToRefresh.rx.isRefreshing)
            .disposed(by: self.disposeBag)
        
        self.tableView.rx.modelSelected(ViewModelType.ModelType.self)
            .subscribe(onNext: strongify(weak: self, closure: { (self, item) in
                self.didSelect(item: item)
            }))
            .disposed(by: self.disposeBag)
    }
    
}

extension ListViewController {
    
    private func createTableView() -> UITableView {
        let tableView = UITableView(frame: .zero,
                                    style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .lightGray
        tableView.register(ListCell.self,
                           forCellReuseIdentifier: type(of: self).cellIdentifier)
        return tableView
    }

    private func createSearchBar() -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.frame = CGRect(x: 0,
                                 y: 0,
                                 width: self.tableView.bounds.width,
                                 height: 50)
        searchBar.searchBarStyle = .default
        searchBar.backgroundColor = .lightGray
        searchBar.searchTextField.backgroundColor = .white
        searchBar.searchTextField.textColor = .darkText
        searchBar.setBackgroundImage(UIColor.lightGray.image(), for: .any, barMetrics: .default)
        searchBar.showsCancelButton = true
        searchBar.placeholder = "Please enter text to start searching..."
        searchBar.keyboardType = .default
        searchBar.autocorrectionType = .no
        searchBar.autocapitalizationType = .none
        return searchBar
    }
    
    private func createPullToRefresh() -> UIRefreshControl {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        return refreshControl
    }
    
    private func createEmptyBackgroundView() -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "No data"
        
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.leftAnchor.constraint(lessThanOrEqualTo: view.leftAnchor, constant: 10).isActive = true
        label.topAnchor.constraint(lessThanOrEqualTo: view.topAnchor, constant: 10).isActive = true
        
        return view
    }
    
    // MARK: setup UI & autolayout
    private func setupUI() {
        self.view.addSubview(self.tableView)
        self.tableView.tableHeaderView = self.searchBar
        self.tableView.backgroundView = self.createEmptyBackgroundView()
        self.tableView.tableFooterView = UIView()
        self.tableView.addSubview(self.pullToRefresh)
        
        self.tableView.backgroundView?.alpha = 1
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 100
    }
    
    private func setupAutoLayout() {
        self.tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
}

extension ListViewController {
    
    private func showAlert(with title: String,
                           message: String) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
}

extension ListViewController {
    
    private func didSelect(item: ViewModelType.ModelType) {
        guard MFMailComposeViewController.canSendMail() else {
            self.showAlert(with: "Error", message: "You can't send an email. Please check your settings.")
            return
        }
        let compose = MFMailComposeViewController()
        compose.mailComposeDelegate = self
        compose.setSubject(item.title)
        compose.setMessageBody(item.description, isHTML: false)
        self.present(compose, animated: true, completion: nil)
    }
    
}

extension ListViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Swift.Error?) {
        guard case .failed = result, let error = error else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        self.dismiss(animated: true, completion: strongify(weak: self, closure: { (self) in
            self.showAlert(with: "Error", message: error.localizedDescription)
        }))
    }
    
}
