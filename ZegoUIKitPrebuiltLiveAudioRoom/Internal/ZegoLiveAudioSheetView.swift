//
//  ZegoLiveAudioSheetView.swift
//  ZegoUIKitPrebuiltLiveAudio
//
//  Created by zego on 2022/11/16.
//

import UIKit

protocol ZegoLiveAudioSheetViewDelegate: AnyObject {
    func didSelectRowForIndex(_ index: Int)
}


class ZegoLiveAudioSheetView: UIView {

    weak var delegate: ZegoLiveAudioSheetViewDelegate?
    
    var dataSource: [String]? {
        didSet {
            self.setupLayout()
            self.tableView.reloadData()
        }
    }
    
    lazy var tableView: UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .plain)
        table.backgroundColor = UIColor.colorWithHexString("#111014")
        table.delegate = self
        table.dataSource = self
        table.register(ZegoLiveAudioSheetCell.self, forCellReuseIdentifier: "ZegoLiveAudioSheetCell")
        return table
    }()
    
    lazy var sheetMaskView: UIView = {
        let view = UIView()
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(tapClick))
        self.sheetMaskView.addGestureRecognizer(tap)
        self.addSubview(self.sheetMaskView)
        self.addSubview(self.tableView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setupLayout()
    }
    
    func setupLayout() {
        self.sheetMaskView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        let height: CGFloat = CGFloat(50 * CGFloat(self.dataSource?.count ?? 0))
        self.tableView.frame = CGRect(x: 0, y: self.frame.size.height - height, width: self.frame.size.width, height: height)
        self.tableView.cornerCut(16, corner: [.topLeft,.topRight])
    }
    
    @objc func tapClick() {
        self.disMiss()
    }
    
    func show(_ onView: UIView) {
        onView.addSubview(self)
    }
    
    func disMiss() {
        self.removeFromSuperview()
    }

}

extension ZegoLiveAudioSheetView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let title: String? = self.dataSource?[indexPath.row] ?? nil
        let cell: ZegoLiveAudioSheetCell = tableView.dequeueReusableCell(withIdentifier: "ZegoLiveAudioSheetCell", for: indexPath) as! ZegoLiveAudioSheetCell
        cell.title = title
        cell.contentView.backgroundColor = UIColor.colorWithHexString("#111014")
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.didSelectRowForIndex(indexPath.row)
        self.disMiss()
    }
    
}

class ZegoLiveAudioSheetCell: UITableViewCell {
    
    var title: String? {
        didSet {
            self.titleLabel.text = title
        }
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .center
        return label
    }()
    
    lazy var lineView: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor.white
        return line
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.lineView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setupLayout()
    }
    
    func setupLayout() {
        self.titleLabel.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height - 0.5)
        self.lineView.frame = CGRect(x: 0, y: self.titleLabel.frame.maxY, width: self.frame.size.width, height: 0.5)
    }
    
}
