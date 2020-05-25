import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:contact_app/models/contact.model.dart';
import 'package:contact_app/android/views/home.view.dart';
import 'package:contact_app/android/views/loading.view.dart';
import 'package:contact_app/android/views/address.view.dart';
import 'package:contact_app/android/views/take-picture.view.dart';
import 'package:contact_app/android/views/crop-picture.view.dart';
import 'package:contact_app/repositories/contact.repository.dart';
import 'package:contact_app/android/views/editor-contact.view.dart';
import 'package:contact_app/shared/widgets/contact-details-image.widget.dart';
import 'package:contact_app/shared/widgets/contact-details-description.widget.dart';

class DetailsView extends StatefulWidget {
  final int id;
  DetailsView({@required this.id});

  @override
  _DetailsViewState createState() => _DetailsViewState();
}

class _DetailsViewState extends State<DetailsView> {
  final _repository = new ContactRepository();

  onDelete() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Exclusão de Contato"),
          content: Text("Deseja excluir este contato?"),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancelar"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(child: Text("Excluir"), onPressed: delete)
          ],
        );
      },
    );
  }

  delete() {
    _repository.delete(widget.id).then((_) {
      onSuccess();
    }).catchError((error) {
      onError(error);
    });
  }

  onSuccess() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomeView()));
  }

  onError(error) {
    print(error);
  }

  takePicture() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TakePictureView(
          camera: firstCamera,
        ),
      ),
    ).then((imagePath) {
      cropPicture(imagePath);
    });
  }

  cropPicture(String path) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CropPictureView(
          path: path,
        ),
      ),
    ).then((imagePath) {
      updateImage(imagePath);
    });
  }

  updateImage(String path) {
    _repository.updateImage(widget.id, path).then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _repository.getContact(widget.id),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          ContactModel contact = snapshot.data;
          return page(context, contact);
        } else {
          return LoadingView();
        }
      },
    );
  }

  Widget page(BuildContext context, ContactModel contact) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contato"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          SizedBox(height: 10, width: double.infinity),
          ContactDetailsImage(image: contact.image),
          SizedBox(height: 10),
          ContactDetailsDescription(
            name: contact.name,
            phone: contact.phone,
            email: contact.email,
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              FlatButton(
                onPressed: () {
                  launch("tel://${contact.phone}");
                },
                color: Theme.of(context).primaryColor,
                shape: CircleBorder(side: BorderSide.none),
                child: Icon(Icons.phone, color: Theme.of(context).accentColor),
              ),
              FlatButton(
                onPressed: () {
                  launch("mailto://${contact.email}");
                },
                color: Theme.of(context).primaryColor,
                shape: CircleBorder(side: BorderSide.none),
                child: Icon(Icons.email, color: Theme.of(context).accentColor),
              ),
              FlatButton(
                onPressed: takePicture,
                color: Theme.of(context).primaryColor,
                shape: CircleBorder(side: BorderSide.none),
                child: Icon(
                  Icons.camera_enhance,
                  color: Theme.of(context).accentColor,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 40,
          ),
          ListTile(
            title: Text(
              "Endereço",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  contact.addressLine1 ?? "Nenhum endereço cadastrado",
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
                Text(
                  contact.addressLine2 ?? "Nenhum endereço cadastrado",
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            isThreeLine: true,
            trailing: FlatButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddressView(model: contact),
                  ),
                );
              },
              child: Icon(
                Icons.pin_drop,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Container(
              width: double.infinity,
              height: 50,
              color: Color(0xFFFF0000),
              child: FlatButton(
                onPressed: onDelete,
                child: Text(
                  "Excluir Contato",
                  style: TextStyle(
                    color: Theme.of(context).accentColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditorContactView(model: contact),
            ),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(
          Icons.edit,
          color: Theme.of(context).accentColor,
        ),
      ),
    );
  }
}
