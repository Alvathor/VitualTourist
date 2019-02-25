//
//  FetchedRCD.swift
//  Virtual Tourist
//
//  Created by Juliano Alvarenga on 24/06/18.
//  Copyright © 2018 Zion. All rights reserved.
//

import Foundation
import CoreData

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {

//        MARK: - NSFetchedResultsControllerDelegate Protocol functions

        func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            
            blockOPerations.removeAll(keepingCapacity: false)
        }

        func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

            let op: BlockOperation
            
            switch type {

            case .insert:
                
                guard let _newIndexPath = newIndexPath else { return }
                op = BlockOperation { self.myCollectionView.insertItems(at: [_newIndexPath]) }
                numberofItens += 1
                
            case .delete:
                
                guard let _indexPath = indexPath else { return }
                op = BlockOperation { self.myCollectionView.deleteItems(at: [_indexPath]) }
                numberofItens -= 1
                
            case .update:
                
                guard let _indexPath = indexPath else { return }
                op = BlockOperation { self.myCollectionView.reloadItems(at: [_indexPath]) }

            case .move:

                guard let _newIndexPath = newIndexPath, let _indexPath = indexPath else { return }
                op = BlockOperation { self.myCollectionView.moveItem(at: _indexPath, to: _newIndexPath) }
            }
            
            blockOPerations.append(op)
        }

        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            
            myCollectionView.performBatchUpdates({
                self.blockOPerations.forEach({ $0.start() })
            }, completion: { finished in
                
                self.blockOPerations.removeAll(keepingCapacity: false)
            })
        }
}
