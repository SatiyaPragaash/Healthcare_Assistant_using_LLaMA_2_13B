class UserModel{
  String? uId;
  String? name;
  String? email;
  String? lang;

  UserModel({ this.uId, this.name, this.email, this.lang});

  factory UserModel.fromMap(map){
    return UserModel(uId: map['Uid'], name: map['Name'], email: map['Email'], lang: map['Lang']);
  }

  Map<String, dynamic> toMap(){
    return{
      'Uid': uId,
      'Name': name,
      'Email': email,
      'Lang' : lang
    };
  }
}