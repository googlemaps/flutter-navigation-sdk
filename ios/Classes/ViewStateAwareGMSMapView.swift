// Copyright 2023 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
import GoogleNavigation

class ViewStateAwareGMSMapView: GMSMapView {
  private var _isSettled: Bool = false
  private var _prevBounds: CGRect = .zero

  weak var viewSettledDelegate: ViewSettledDelegate? {
    didSet {
      // Call didSet immediately if isSettled is true
      if _isSettled, let delegate = viewSettledDelegate {
        delegate.onViewSettled(self)
        viewSettledDelegate = nil
      }
    }
  }

  func checkSettled() {
    if _isSettled { return }
    if superview == nil { return }
    if bounds.size.width != 0, bounds.size.height != 0 {
      _isSettled = true
      viewSettledDelegate?.onViewSettled(self)
      viewSettledDelegate = nil
    }
  }

  override public func layoutSubviews() {
    if !_isSettled, bounds != _prevBounds {
      _prevBounds = bounds
      checkSettled()
    }

    super.layoutSubviews()
  }
}
