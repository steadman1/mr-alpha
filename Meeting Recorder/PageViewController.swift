//
//  PageViewController.swift
//  Meeting Recorder
//
//  Created by Spencer Steadman on 9/9/21.
//

import SwiftUI
import UIKit

class PageViewController: UIViewController, View {
    
    private let scrollView = UIScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scrollView)
        
    }
    
    override func viewDidLayoutSubviews() {
        scrollView.frame =
            CGRect(x: 0,
                   y: 0,
                   width: view.frame.size.width,
                   height: view.frame.size.height)
        
        if scrollView.subviews.count == 2 {
            configureScrollView()
        }
        
    }
    
    private func configureScrollView() {
        scrollView.contentSize =
            CGSize(width: view.frame.size.width * 2,
                   height: scrollView.frame.size.height)
        scrollView.isPagingEnabled = true;
        
        for i in 0..<2 {
            let page = UIView(
                frame: CGRect(
                    x: CGFloat(i),
                    y: 0,
                    width: view.frame.size.width,
                    height: view.frame.size.height))
            
            page.backgroundColor = .systemRed
            scrollView.addSubview(page)
        }
    }
    
    var body: some View {
        scrollView.superview
    }
}
