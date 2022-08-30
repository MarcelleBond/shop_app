import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = "/edit-product";
  const EditProductScreen({Key? key}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  var _editProduct = Product(
    id: "",
    title: "",
    description: "",
    price: 0.0,
    imageUrl: "",
  );
  var _initValues = {
    "title": "",
    "price": "",
    "description": "",
    "imageUrl": "",
  };
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    _imageUrlController.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        var productid = ModalRoute.of(context)?.settings.arguments as String;

        _editProduct = Provider.of<Products>(context).findById(productid);
        _initValues = {
          "title": _editProduct.title,
          "price": _editProduct.price.toString(),
          "description": _editProduct.description,
          "imageUrl": "",
        };
        _imageUrlController.text = _editProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.removeListener(_updateImageUrl);
    _imageUrlController.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    var isValed = _form.currentState?.validate();
    if (!isValed!) return;

    _form.currentState?.save();
    setState(() {
      _isLoading = true;
    });

    if (_editProduct.id.isNotEmpty) {
      await Provider.of<Products>(context, listen: false).updateProduct(_editProduct.id, _editProduct);
    } else {
      try {
        Provider.of<Products>(context, listen: false).addProduct(_editProduct);
      } catch (e) {
        await showDialog<Null>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("An error occurred!"),
            content: const Text("Something went wrong."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }
    Navigator.of(context).pop();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Product"),
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: _initValues["title"],
                        decoration: const InputDecoration(labelText: "Title"),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => FocusScope.of(context)
                            .requestFocus(_priceFocusNode),
                        validator: (value) {
                          if (value!.isEmpty) return "Please provide a title.";
                          return null;
                        },
                        onSaved: (newValue) => _editProduct = Product(
                            id: _editProduct.id,
                            title: newValue!,
                            description: _editProduct.description,
                            imageUrl: _editProduct.imageUrl,
                            price: _editProduct.price,
                            isFavorite: _editProduct.isFavorite),
                      ),
                      TextFormField(
                        initialValue: _initValues["price"],
                        decoration: const InputDecoration(labelText: "Price"),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        focusNode: _priceFocusNode,
                        onFieldSubmitted: (_) => FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode),
                        validator: (value) {
                          if (value!.isEmpty) return "Please provide a price.";
                          if (double.tryParse(value) == null) {
                            return "Please enter a valied number.";
                          }
                          if (double.parse(value) <= 0) {
                            return "Please enter a number greater than.";
                          }
                          return null;
                        },
                        onSaved: (newValue) => _editProduct = Product(
                            id: _editProduct.id,
                            title: _editProduct.title,
                            description: _editProduct.description,
                            imageUrl: _editProduct.imageUrl,
                            price: double.parse(newValue!),
                            isFavorite: _editProduct.isFavorite),
                      ),
                      TextFormField(
                        initialValue: _initValues["description"],
                        decoration:
                            const InputDecoration(labelText: "Description"),
                        autocorrect: true,
                        textInputAction: TextInputAction.next,
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        focusNode: _descriptionFocusNode,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please provide a description.";
                          }
                          if (value.length < 10) {
                            return "Should have at leaste 10 characters.";
                          }
                          return null;
                        },
                        onSaved: (newValue) => _editProduct = Product(
                            id: _editProduct.id,
                            title: _editProduct.title,
                            description: newValue!,
                            imageUrl: _editProduct.imageUrl,
                            price: _editProduct.price,
                            isFavorite: _editProduct.isFavorite),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            height: 100,
                            width: 100,
                            alignment: Alignment.center,
                            margin: const EdgeInsets.only(
                              top: 8,
                              right: 10,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Colors.grey,
                              ),
                            ),
                            child: _imageUrlController.text.isEmpty
                                ? const Text("Enter Image Url")
                                : Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.contain,
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                              decoration:
                                  const InputDecoration(labelText: 'Image URL'),
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.done,
                              controller: _imageUrlController,
                              onEditingComplete: () {
                                setState(() {});
                              },
                              focusNode: _imageUrlFocusNode,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please provide a image url.";
                                }
                                if (!value.startsWith("http") &&
                                    !value.startsWith("https")) {
                                  return "Please enter a valied url.";
                                }
                                if (!value.endsWith(".png") &&
                                    !value.endsWith(".jpg") &&
                                    !value.endsWith(".jpeg")) {
                                  return "Please enter a valied image url.";
                                }
                                return null;
                              },
                              onFieldSubmitted: (value) => _saveForm,
                              onSaved: (newValue) => _editProduct = Product(
                                  id: _editProduct.id,
                                  title: _editProduct.title,
                                  description: _editProduct.description,
                                  imageUrl: newValue!,
                                  price: _editProduct.price,
                                  isFavorite: _editProduct.isFavorite),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
