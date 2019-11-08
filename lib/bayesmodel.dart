class Match {
  int id;
  String perid;
  int state;
  String stateLabel;
  String dateStart;
  Title title;
  Tournament tournament;
  List<Team> teams;
  List<Link> links;
  List<Results> results;

  Match(
      {this.id,
      this.perid,
      this.state,
      this.stateLabel,
      this.dateStart,
      this.title,
      this.tournament,
      this.teams,
      this.links,
      this.results});

  Match.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    perid = json['perid'];
    state = json['state'];
    stateLabel = json['state_label'];
    dateStart = json['date_start'];
    title = json['title'] != null ? Title.fromJson(json['title']) : null;
    tournament = json['tournament'] != null
        ? Tournament.fromJson(json['tournament'])
        : null;
    if (json['teams'] != null) {
      teams = List<Team>();
      json['teams'].forEach((v) {
        teams.add(Team.fromJson(v));
      });
    }
    if (json['links'] != null) {
      links = List<Link>();
      json['links'].forEach((v) {
        links.add(new Link.fromJson(v));
      });
    }
    if (json['results'] != null) {
      results = List<Results>();
      json['results'].forEach((v) {
        results.add(Results.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['perid'] = this.perid;
    data['state'] = this.state;
    data['state_label'] = this.stateLabel;
    data['date_start'] = this.dateStart;
    if (this.title != null) {
      data['title'] = this.title.toJson();
    }
    if (this.tournament != null) {
      data['tournament'] = this.tournament.toJson();
    }
    if (this.teams != null) {
      data['teams'] = this.teams.map((v) => v.toJson()).toList();
    }
    if (this.links != null) {
      data['links'] = this.links.map((v) => v.toJson()).toList();
    }
    if (this.results != null) {
      data['results'] = this.results.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Title {
  int id;
  String perid;
  String name;
  String abbreviation;
  List<String> links;

  Title({this.id, this.perid, this.name, this.abbreviation, this.links});

  Title.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    perid = json['perid'];
    name = json['name'];
    abbreviation = json['abbreviation'];
    if (json['links'] != null) {
      links = json['links'].cast<String>();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['perid'] = this.perid;
    data['name'] = this.name;
    data['abbreviation'] = this.abbreviation;
    if (this.links != null) {
      data['links'] = this.links;
    }
    return data;
  }
}

class Tournament {
  int id;
  String perid;
  String dateStart;
  String name;
  String fullName;

  Tournament({this.id, this.perid, this.dateStart, this.name});

  Tournament.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    perid = json['perid'];
    dateStart = json['date_start'];
    name = json['name'];
    fullName = json['full_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['perid'] = this.perid;
    data['date_start'] = this.dateStart;
    data['name'] = this.name;
    data['full_name'] = this.fullName;
    return data;
  }
}

class Team {
  int id;
  String perid;
  String abbreviation;
  String name;

  Team({this.id, this.perid, this.abbreviation, this.name});

  Team.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    perid = json['perid'];
    abbreviation = json['abbreviation'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['perid'] = this.perid;
    data['abbreviation'] = this.abbreviation;
    data['name'] = this.name;
    return data;
  }
}

class Link {
  String url;
  String type;
  String provider;

  Link({this.url, this.type, this.provider});

  Link.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    type = json['type'];
    provider = json['provider'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    data['type'] = this.type;
    data['provider'] = this.provider;
    return data;
  }
}

class Results {
  int teamId;
  int score;
  bool winner;

  Results({this.teamId, this.score, this.winner});

  Results.fromJson(Map<String, dynamic> json) {
    teamId = json['team_id'];
    score = json['score'];
    winner = json['winner'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['team_id'] = this.teamId;
    data['score'] = this.score;
    data['winner'] = this.winner;
    return data;
  }
}