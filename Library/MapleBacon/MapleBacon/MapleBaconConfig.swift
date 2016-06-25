//
//  MapleBaconConfig.swift
//  MapleBacon
//
//  Created by Danilo Topalovic on 10.03.16.
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import Foundation
import UIKit

/**
 * MapleBacon Config
 */
public class MapleBaconConfig {
    
    /// singleton param
    public static let sharedConfig: MapleBaconConfig = MapleBaconConfig()
    
    /// Holds the storage part of the config
    var storage: Storage
    
    /**
     Private Constructor
     inits default config
     */
    private init() {
        self.storage = MapleBaconConfig.Storage.defaultStorage()
    }
    
    /**
     * Storage Class
     * Holds all configuration for the storage
     * part of MapleBacon
     */
    class Storage {
        
        /// used for idents and/or paths of the storage engines
        var defaultStorageName: String = ""
        /// used for dispatch and/or serial queues
        var queueLabel: String = ""
        /// basepath of the storage (disk)
        var baseStoragePath: String = ""
        /// the rootUUIDNamespace should be either ns:URL or ns:DNS -> http://www.ietf.org/rfc/rfc4122.txt
        var rootUUIDNamespace: String = ""
        /// should be the bundle-id or other unique app ident
        var baseUUIDName: String = ""
        /// use UUID Idents instead of clean sha1
        var useUUID: Bool = true
        
        /**
         Returns a storage class filled with defaults
         
         - returns: the default storage class
         */
        class func defaultStorage() -> MapleBaconConfig.Storage {
            return Storage {
                $0.defaultStorageName = "default"
                $0.queueLabel = "de.zalando.MapleBacon.Storage"
                $0.baseStoragePath = "de.zalando.MapleBacon."
                // defaults to ns:URL in RFC4122 -> http://www.ietf.org/rfc/rfc4122.txt
                $0.rootUUIDNamespace = "6ba7b811-9dad-11d1-80b4-00c04fd430c8"
                $0.baseUUIDName = "de.zalando.MapleBacon.imagestore"
                $0.useUUID = true
            }
        }
        
        /**
         Easy init
         allows to set all values (or some) within the 
         constructor
         */
        init( _ initialize: @noescape(Storage) -> Void = { _ in }) {
            initialize(self)
        }
    }
}
