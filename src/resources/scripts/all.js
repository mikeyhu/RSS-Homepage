// Generated by CoffeeScript 1.6.1
(function() {
  var controller, states;

  controller = typeof exports !== "undefined" && exports !== null ? exports : this;

  states = {
    NEW: "new",
    ARCHIVED: "archived",
    STARRED: "starred"
  };

  controller.EntryListCtrl = function($scope, $http) {
    $scope.tags = [
      {
        name: "All"
      }, {
        name: "Technology"
      }, {
        name: "News"
      }, {
        name: "Sport"
      }
    ];
    $scope.selectedTag = $scope.tags[0];
    $scope.entries = [];
    $scope.refreshEntries = function() {
      var url;
      if ($http) {
        url = $scope.selectedTag.name === "All" ? "/latest/json" : "/latestByTag/json?tag=" + $scope.selectedTag.name;
        return $http.get(url).success(function(data, status) {
          return $scope.entries = data;
        }).error(function(data, status) {});
      }
    };
    $scope.changeState = function(entry, state) {
      var ignoreOutput;
      ignoreOutput = function(data, status) {};
      if ($http) {
        return $http.get("/changeState?state=" + state + "&id=" + $scope.encode(entry.id)).success(ignoreOutput).error(ignoreOutput);
      }
    };
    $scope.findNew = function() {
      var entry, _i, _len, _ref, _results;
      _ref = $scope.entries;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        entry = _ref[_i];
        if (entry.state === states.NEW) {
          _results.push(entry);
        }
      }
      return _results;
    };
    $scope.remove = function(index) {
      var entry;
      entry = $scope.entries[index];
      $scope.entries.splice(index, 1);
      return $scope.changeState(entry, states.ARCHIVED);
    };
    $scope.star = function(index) {
      var entry;
      entry = $scope.entries[index];
      if (entry.state === states.STARRED) {
        entry.state = states.NEW;
      } else {
        entry.state = states.STARRED;
      }
      return $scope.changeState(entry, entry.state);
    };
    $scope.read = function(index) {
      $scope.entries.splice(index, 1);
      return true;
    };
    $scope.archiveAllNew = function() {
      var entry, newIds;
      newIds = (function() {
        var _i, _len, _ref, _results;
        _ref = $scope.findNew();
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          entry = _ref[_i];
          _results.push(entry.id);
        }
        return _results;
      })();
      console.log(newIds);
      if ($http) {
        return $http.post("/changeMultipleStates?state=" + states.ARCHIVED, newIds).success(function(data, status) {
          return $scope.refreshEntries();
        }).error(function(data, status) {});
      }
    };
    $scope.encode = function(url) {
      return encodeURIComponent(url);
    };
    $scope.plusMinus = function(open) {
      if (open) {
        return "minus";
      } else {
        return "plus";
      }
    };
    $scope.status = function(state) {
      if (state === states.STARRED) {
        return "";
      } else {
        return "-empty";
      }
    };
    $scope.refreshEntries();
    return {
      scope: $scope
    };
  };

  controller = typeof exports !== "undefined" && exports !== null ? exports : this;

  controller.FeedListCtrl = function($scope, $http) {
    $scope.newURL = '';
    $scope.newTags = '';
    $scope.feeds = [];
    $scope.ignoreOutput = function(data) {
      return console.log(data);
    };
    $scope.newFeed = function() {};
    $scope.refreshFeeds = function() {
      if ($http) {
        return $http.get("/feeds/json").success(function(data, status) {
          return $scope.feeds = data;
        }).error(function(data, status) {});
      }
    };
    $scope.addFeed = function() {
      var feed;
      feed = {
        URL: $scope.newURL,
        tags: [$scope.newTags]
      };
      $scope.newURL = '';
      $scope.newTags = '';
      $scope.feeds.push(feed);
      if ($http) {
        return $http.get("/insertFeed?URL=" + $scope.encode(feed.URL) + "&tags=" + $scope.encode(feed.tags)).success(ignoreOutput).error(ignoreOutput);
      }
    };
    $scope.encode = function(data) {
      return encodeURIComponent(data);
    };
    $scope.removeFeed = function(index) {
      return $scope.feeds.splice(index, 1);
    };
    $scope.refreshFeeds();
    return {
      scope: $scope
    };
  };

}).call(this);
