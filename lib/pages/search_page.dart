import 'package:flutter/material.dart';
import 'package:social_media/pages/profile.dart';
import 'package:social_media/service/firestore_service.dart';

import '../models/user.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController=TextEditingController();
  Future<List<UserObject>> searchList = Future<List<UserObject>>.value([]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      // ignore: unnecessary_null_comparison
      body: searchList!=null? getSearchList():notSearch(),
    );
  }

  AppBar buildAppBar() => AppBar(
    titleSpacing: 0,
    title: TextFormField(
      cursorColor: Colors.indigo,
      controller: searchController,
      onFieldSubmitted: (enteredText){
        setState(() {
          searchList= FireStoreService().searchUser(enteredText);
        });

      },
      decoration: InputDecoration(
        disabledBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        filled: true,
        contentPadding: const EdgeInsets.only(top:15),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20)),
        hintText:"Kullanıcı Ara",
        prefixIcon: const Icon(Icons.search,size: 30),
        suffixIcon: IconButton(
          onPressed: (){
            searchController.clear();
            // ignore: cast_from_null_always_fails
            searchList=null as Future<List<UserObject>>;
          },
          icon: const Icon(Icons.clear),),

      ),

    ),
  );

  notSearch() {
    return const Center(
        child:  Text("Arama Yok"));
  }

  getSearchList() {
    return FutureBuilder(
        future: searchList,
      builder: (context, snapshot){
          if(!snapshot.hasData){
            return const Center(child:  CircularProgressIndicator());
          }if(snapshot.data!.isEmpty){
            return const Center(child: Text("Diğer Kullanıcıları Arayın"));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder:(context,index){
              UserObject user=snapshot.data![index];
              return searchCard(user);
            } ,
          );
      },
    );
  }

  searchCard(UserObject user) {
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>Profile(currentProfileId: user.id)));
      },
      child: Card(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: ListTile(
                    leading: CircleAvatar(
                        backgroundImage: NetworkImage(user.fotoUrl)
                    ),
                    title: Text(user.kullaniciAdi,style: const TextStyle(fontWeight: FontWeight.bold),),
                  )
      ),
    );
  }
}
