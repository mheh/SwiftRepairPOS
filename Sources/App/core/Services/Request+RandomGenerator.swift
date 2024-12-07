//
//  Request+RandomGenerator.swift
//  SwiftRepairPOS
//
//  Created by Milo Hehmsoth on 12/6/24.
//

// From madsodgaard
// https://github.com/madsodgaard/vapor-auth-template/tree/main/Sources/App/Services/RandomGenerator

import Vapor

import Crypto

public protocol RandomGenerator {
    func generate(bits: Int) -> String
}

extension Application {
    public struct RandomGenerators {
        public struct Provider {
            let run: ((Application) -> Void)
        }
        
        public let app: Application
        
        
        public func use(_ provider: Provider) {
            provider.run(app)
        }
        
        public func use(_ makeGenerator: @escaping ((Application) -> RandomGenerator)) {
            storage.makeGenerator = makeGenerator
        }
        
        final class Storage: @unchecked Sendable {
            var makeGenerator: ((Application) -> RandomGenerator)?
            init() {}
        }
        
        private struct Key: StorageKey {
            typealias Value = Storage
        }
        
        var storage: Storage {
            if let existing = self.app.storage[Key.self] {
                return existing
            } else {
                let new = Storage()
                self.app.storage[Key.self] = new
                return new
            }
        }
    }
    
    public var randomGenerators: RandomGenerators {
        .init(app: self)
    }
}


extension Application {
    public var random: AppRandomGenerator {
        .init(app: self)
    }
    
    public struct AppRandomGenerator: RandomGenerator {
        let app: Application
        
        var generator: RandomGenerator {
            guard let makeGenerator = app.randomGenerators.storage.makeGenerator else {
                fatalError("randomGenerators not configured, please use: app.randomGenerators.use")
            }
            
            return makeGenerator(app)
        }
        
        public func generate(bits: Int) -> String {
            generator.generate(bits: bits)
        }
    }
}


extension Application.RandomGenerators.Provider {
    static var random: Self {
        .init {
            $0.randomGenerators.use { _ in RealRandomGenerator() }
        }
    }
}

struct RealRandomGenerator: RandomGenerator {
    func generate(bits: Int) -> String {
        [UInt8].random(count: bits / 8).hex
    }
}

extension Request {
    var random: RandomGenerator {
        self.application.random
    }
}
