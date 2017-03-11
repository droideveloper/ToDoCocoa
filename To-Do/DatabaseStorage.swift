/*
 * To-Do Copyright (C) 2017 Fatih.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
 
import SugarRecordCoreData
import RxSwift

import MVVMCocoa

enum PersistanceError: Error {
	case noSuchEntity;
}

class DatabaseStorage: NSObject, DatabaseStorageType, LogType {
	
	fileprivate var dbContext: CoreDataDefaultStorage;
	fileprivate let DB_NAME = "todo";
	
	override init() {
		let store = CoreDataStore.named(DB_NAME);
		let bundle = Bundle(for: DatabaseStorage.classForCoder());
		let model = CoreDataObjectModel.merged([bundle]);
		if let dbContext = try? CoreDataDefaultStorage(store: store, model: model) {
			self.dbContext = dbContext;
		} else {
			fatalError("can not create CoreData");
		}
	}
	
	func create<T : Entity>(_ create: @escaping (Context) throws -> T) -> Observable<T> {
		return dbContext.rx.create(create);
	}
	
	func update<T : Entity>(_ update: @escaping (Context) throws -> T?) -> Observable<T> {
		return dbContext.rx.update(update);
	}
	
	func delete<T : Entity>(_ delete: @escaping (Context) throws -> T?) -> Observable<T> {
		return dbContext.rx.delete(delete);
	}
	
	func queryAll<T : Entity>() -> Observable<[T]> {
		return dbContext.rx.queryAll();
	}
	
	func isLogEnabled() -> Bool {
		return BuildConfig.DEBUG;
	}

	func getClassTag() -> String {
		return String(describing: DatabaseStorage.self);
	}
}
