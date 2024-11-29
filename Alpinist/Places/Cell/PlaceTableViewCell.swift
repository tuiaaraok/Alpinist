//
//  PlaceTableViewCell.swift
//  Alpinist
//
//  Created by Karen Khachatryan on 29.11.24.
//

import UIKit
import FSPagerView
import PhotosUI

class PlaceTableViewCell: UITableViewCell {

    @IBOutlet weak var pagerView: FSPagerView!
    @IBOutlet weak var pageControl: FSPageControl!
    @IBOutlet var labels: [UILabel]!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    private var place: PlaceModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        pagerView.layer.masksToBounds = true
        pagerView.dataSource = self
        pagerView.delegate = self
        pagerView.contentMode = .center
        pagerView.transformer = FSPagerViewTransformer(type: .linear)
        pagerView.itemSize = pagerView.bounds.size
        pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        pagerView.itemSize = pagerView.bounds.size
        pagerView.layer.borderColor = UIColor.white.cgColor
        pagerView.layer.borderWidth = 2
        pageControl.contentHorizontalAlignment = .center
        pageControl.setFillColor(.white, for: .selected)
        pageControl.setFillColor(.black, for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        place = nil
    }
    
    func configure(place: PlaceModel) {
        self.place = place
        nameLabel.text = place.name
        dateLabel.text = place.startDate?.toString()
        heightLabel.text = "\(place.height ?? 0)m"
        if let startDate = place.startDate, let endDate = place.endDate {
            let date = (endDate.stripTime() > Date().stripTime()) ? Date().stripTime() : endDate.stripTime()
            if startDate.stripTime() >= Date().stripTime() {
                durationLabel.text = "\(startDate.daysDifference(to: endDate)) days"
            } else {
                durationLabel.text = "\(startDate.daysDifference(to: date)) days"
            }
        }
        pagerView.reloadData()
        self.pageControl.numberOfPages = (place.photo.count + place.video.count)
    }
    
    private func writeVideoToTempFile(videoData: Data) -> URL? {
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileName = UUID().uuidString + ".mp4"
        let fileURL = tempDirectory.appendingPathComponent(fileName)

        do {
            try videoData.write(to: fileURL)
            return fileURL
        } catch {
            print("Error writing video data to temporary file: \(error)")
            return nil
        }
    }
}

extension PlaceTableViewCell: FSPagerViewDataSource, FSPagerViewDelegate {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        if let place = place {
            return (place.photo.count + place.video.count)
        }
        return 0
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        guard let place = place else { return FSPagerViewCell() }
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        if index < place.photo.count {
            cell.imageView?.isHidden = false
            let data = place.photo[index]
            cell.imageView?.contentMode = .scaleAspectFill
            cell.imageView?.image = UIImage(data: data)
            removeVideoLayer(from: cell)
        } else {
            cell.imageView?.isHidden = true
            let data = place.video[index - place.photo.count]
            if let videoURL = writeVideoToTempFile(videoData: data) {
                playVideo(in: cell, from: videoURL)
            }
        }
        return cell
    }
        
    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        pageControl.currentPage = pagerView.currentIndex
    }
    
    func pagerView(_ pagerView: FSPagerView, shouldSelectItemAt index: Int) -> Bool {
        return true
    }
    
    private func playVideo(in cell: FSPagerViewCell, from url: URL) {
        let player = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = cell.bounds
        playerLayer.videoGravity = .resizeAspectFill
        cell.layer.addSublayer(playerLayer)
        player.play()
    }
    
    private func removeVideoLayer(from cell: FSPagerViewCell) {
        if let sublayers = cell.layer.sublayers {
            for layer in sublayers where layer is AVPlayerLayer {
                layer.removeFromSuperlayer()
            }
        }
    }
}
