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

  controller.FeedListCtrl = function($scope) {
    $scope.feedURL = '';
    $scope.listData = [
      {
        url: "http://feeds.bbci.co.uk/news/rss.xml"
      }, {
        url: "http://www.theverge.com/rss/index.xml"
      }
    ];
    $scope.addFeed = function() {
      $scope.listData.push({
        url: $scope.feedURL
      });
      return $scope.feedURL = '';
    };
    return {
      scope: $scope
    };
  };

}).call(this);
