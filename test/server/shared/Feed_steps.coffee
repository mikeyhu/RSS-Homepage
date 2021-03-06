exports.insertingSome = (entries)=>
	intoThe:(store,finish)=>
		store.insertEntries entries,(err,result)=>
			throw err if err
			finish result

exports.inserting = (entry)=>
	intoThe:(store,finish)=>
		store.insertEntry entry,(err,result)=>
			throw err if err
			finish result

exports.countingEntriesInThe = (store,finish)=>
	store.count (err,result)=>
		throw err if err
		finish result

exports.clearingDataFromThe = (store,finish)=>
	store.clear (err,result)=>
		throw err if err
		finish result

exports.addingSomeFeeds = (feeds)=>
	intoThe:(store,finish)=>
		store.insertFeeds feeds,(err,result)=>
			throw err if err
			finish result

