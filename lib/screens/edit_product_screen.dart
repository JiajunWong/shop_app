import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/library/models/product_model.dart';
import 'package:shop_app/library/providers/products_provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  const EditProductScreen({Key? key}) : super(key: key);

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageFocusNode = FocusNode();
  final _imageURLController = TextEditingController();
  final _form = GlobalKey<FormState>();
  ProductModel _editedProduct =
      ProductModel(id: '', title: '', description: '', imageUrl: '', price: 0);
  var _isInit = false;
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };
  var _isLoading = false;

  @override
  void initState() {
    _imageFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) return;
    _isInit = true;
    final productId = ModalRoute.of(context)!.settings.arguments as String?;
    if (productId == null || productId.isEmpty) return;
    _editedProduct = Provider.of<ProductsProvider>(context, listen: false)
        .findById(productId);
    _imageURLController.text = _editedProduct!.imageUrl!;
    _initValues = {
      'title': _editedProduct!.title!,
      'description': _editedProduct!.description!,
      'price': _editedProduct!.price.toString(),
      'imageUrl': _editedProduct!.imageUrl!,
    };
  }

  void _updateImageUrl() {
    if (!_imageFocusNode.hasFocus) {
      if (!_imageURLController.text.startsWith('http') ||
          !_imageURLController.text.startsWith('https')) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState!.validate();
    if (isValid) {
      _form.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      try {
        await Provider.of<ProductsProvider>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('An error occurred'),
                  content: Text('something went wrong.'),
                  actions: [
                    FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('ok'))
                  ],
                ));
      } finally {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageFocusNode.removeListener(_updateImageUrl);
    _imageFocusNode.dispose();
    _imageURLController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit product'),
        actions: [IconButton(icon: Icon(Icons.save), onPressed: _saveForm)],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator.adaptive(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _initValues['title'],
                      decoration: const InputDecoration(
                        labelText: 'Title',
                      ),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please provide a value.';
                        } else {
                          return null;
                        }
                      },
                      onSaved: (value) {
                        _editedProduct = ProductModel(
                            title: value!,
                            price: _editedProduct!.price,
                            imageUrl: _editedProduct!.imageUrl,
                            id: _editedProduct!.id,
                            description: _editedProduct!.description);
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['price'],
                      decoration: const InputDecoration(
                        labelText: 'Price',
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (value) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please provide a price.';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please entered a valid number';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Please entered a valid number great than 0';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = ProductModel(
                            title: _editedProduct!.title,
                            price: double.parse(value!),
                            imageUrl: _editedProduct!.imageUrl,
                            id: _editedProduct!.id,
                            description: _editedProduct!.description);
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['description'],
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.next,
                      focusNode: _descriptionFocusNode,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please provide a description.';
                        } else if (value.length < 10) {
                          return 'Please provide a longer description.';
                        } else {
                          return null;
                        }
                      },
                      onSaved: (value) {
                        _editedProduct = ProductModel(
                            title: _editedProduct!.title,
                            price: _editedProduct!.price,
                            imageUrl: _editedProduct!.imageUrl,
                            id: _editedProduct!.id,
                            description: value!);
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(top: 8, right: 10),
                          decoration: BoxDecoration(
                              border: Border.all(
                            width: 1,
                            color: Colors.grey,
                          )),
                          child: _imageURLController.text.isEmpty
                              ? Text('Enter a url')
                              : FittedBox(
                                  child:
                                      Image.network(_imageURLController.text),
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            // initialValue: _initValues['imageUrl'],
                            decoration: const InputDecoration(
                              labelText: 'Image Url',
                            ),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageURLController,
                            focusNode: _imageFocusNode,
                            onFieldSubmitted: (value) => _saveForm(),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please provide a image URL.';
                              } else if (!value.startsWith('http') &&
                                  !value.startsWith('https')) {
                                return 'Please provide a valid URL.';
                              } else {
                                return null;
                              }
                            },
                            onSaved: (value) {
                              _editedProduct = ProductModel(
                                  title: _editedProduct!.title,
                                  price: _editedProduct!.price,
                                  imageUrl: value!,
                                  id: _editedProduct!.id,
                                  description: _editedProduct!.description);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
