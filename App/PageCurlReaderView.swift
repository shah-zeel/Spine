import SwiftUI
import UIKit

struct PageCurlReaderView: UIViewControllerRepresentable {
  var pages: [BookPage]
  @Binding var pageIndex: Int
  var showsSpread: Bool
  var notebook: ReaderNotebook
  var activeSpeechLine: SpeechLine?
  var onSelectionChange: (SelectedPassage?) -> Void

  func makeCoordinator() -> Coordinator {
    Coordinator(parent: self)
  }

  func makeUIViewController(context: Context) -> UIPageViewController {
    let spine = showsSpread ? UIPageViewController.SpineLocation.mid : .min
    let controller = UIPageViewController(
      transitionStyle: .pageCurl,
      navigationOrientation: .horizontal,
      options: [.spineLocation: spine.rawValue]
    )
    controller.isDoubleSided = showsSpread
    controller.view.backgroundColor = UIColor(FolioPalette.pageShade)
    controller.dataSource = context.coordinator
    controller.delegate = context.coordinator
    context.coordinator.pageController = controller
    let index = normalized(pageIndex)
    controller.setViewControllers(context.coordinator.controllers(for: index), direction: .forward, animated: false)
    context.coordinator.displayedIndex = index
    return controller
  }

  func updateUIViewController(_ controller: UIPageViewController, context: Context) {
    let coordinator = context.coordinator
    coordinator.parent = self
    coordinator.pageController = controller
    coordinator.refreshHostedPages()

    let targetIndex = normalized(pageIndex)
    guard coordinator.displayedIndex != targetIndex else { return }
    let direction: UIPageViewController.NavigationDirection = targetIndex > coordinator.displayedIndex ? .forward : .reverse
    coordinator.displayedIndex = targetIndex
    controller.setViewControllers(coordinator.controllers(for: targetIndex), direction: direction, animated: true)
  }

  private func normalized(_ index: Int) -> Int {
    guard !pages.isEmpty else { return 0 }
    var safe = min(max(index, 0), pages.count - 1)
    if showsSpread {
      safe = safe.isMultiple(of: 2) ? min(safe + 1, pages.count - 1) : safe
    }
    return safe
  }

  final class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    var parent: PageCurlReaderView
    weak var pageController: UIPageViewController?
    var displayedIndex = 0
    private var hostedPages: [Int: UIHostingController<BookPageView>] = [:]

    init(parent: PageCurlReaderView) {
      self.parent = parent
    }

    func controllers(for requestedIndex: Int) -> [UIViewController] {
      let index = safeIndex(requestedIndex)
      if parent.showsSpread {
        let rightIndex = index.isMultiple(of: 2) ? min(index + 1, parent.pages.count - 1) : index
        let leftIndex = max(rightIndex - 1, 0)
        return [controller(for: leftIndex), controller(for: rightIndex)]
      }
      return [controller(for: index)]
    }

    func pageViewController(
      _ pageViewController: UIPageViewController,
      viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
      guard let index = pageIndex(of: viewController), index > 0 else { return nil }
      return controller(for: index - 1)
    }

    func pageViewController(
      _ pageViewController: UIPageViewController,
      viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
      guard let index = pageIndex(of: viewController), index + 1 < parent.pages.count else { return nil }
      return controller(for: index + 1)
    }

    func pageViewController(
      _ pageViewController: UIPageViewController,
      spineLocationFor orientation: UIInterfaceOrientation
    ) -> UIPageViewController.SpineLocation {
      parent.showsSpread ? .mid : .min
    }

    func pageViewController(
      _ pageViewController: UIPageViewController,
      didFinishAnimating finished: Bool,
      previousViewControllers: [UIViewController],
      transitionCompleted completed: Bool
    ) {
      guard completed,
        let indices = pageViewController.viewControllers?.compactMap(pageIndex(of:)),
        let furthestPage = indices.max() else { return }
      let current = safeIndex(furthestPage)
      let normalizedIndex = parent.showsSpread && current.isMultiple(of: 2)
        ? min(current + 1, parent.pages.count - 1)
        : current
      displayedIndex = normalizedIndex
      parent.pageIndex = normalizedIndex
    }

    func refreshHostedPages() {
      for (index, host) in hostedPages {
        host.rootView = pageView(for: index)
      }
    }

    private func controller(for index: Int) -> UIHostingController<BookPageView> {
      if let existing = hostedPages[index] {
        existing.rootView = pageView(for: index)
        return existing
      }
      let host = UIHostingController(rootView: pageView(for: index))
      host.view.backgroundColor = UIColor(FolioPalette.page)
      hostedPages[index] = host
      return host
    }

    private func pageView(for index: Int) -> BookPageView {
      let safe = safeIndex(index)
      let page = parent.pages[safe]
      return BookPageView(
        page: page,
        notebook: parent.notebook,
        activeSpeechLine: parent.activeSpeechLine,
        onSelectionChange: parent.onSelectionChange
      )
    }

    private func pageIndex(of viewController: UIViewController) -> Int? {
      guard let host = viewController as? UIHostingController<BookPageView> else { return nil }
      return hostedPages.first(where: { $0.value === host })?.key
    }

    private func safeIndex(_ index: Int) -> Int {
      min(max(index, 0), max(parent.pages.count - 1, 0))
    }
  }
}
