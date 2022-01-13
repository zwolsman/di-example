//
// Created by Marvin Zwolsman on 13/01/2022.
//

import Foundation
import Combine
import Moya
import SwiftUI

struct Problem: Codable, Error, Identifiable {
    var id: String {
        title
    }
    var title: String
    var status: Int?
    var detail: String
}

extension Publisher where Failure == MoyaError {
    func extractProblem() -> Publishers.MapError<Self, Problem> {
        mapError { error in
            guard let problem = try? error.response?.map(Problem.self) else {
                return Problem.generic
            }

            return problem
        }
    }
}

extension Loadable {
    var problem: Problem? {
        error as? Problem
    }
}

extension Problem {
    static var generic: Problem = Problem(title: "Oops..", detail: "Something went wrong")

    var alert: Alert {
        Alert(title: Text(title), message: Text(detail))
    }
}
