
import xmltree, strtabs

type
  SoapEncoder* = object

template xmlns* (name, uri: string) {.pragma.} ## Marks the namespace for a struct or field.
template xmlkey* (name: string) {.pragma.} ## Field is stored as a tag with a given name.
template xmlattribute* {.pragma.} ## Field is stored as an attribute of its parent.

proc envelope*(self: var SoapEncoder): XmlNode =
  result = new_element("soap:Envelope")
  let attrs = new_string_table(
    "xmlns:soap", "http://www.w3.org/2003/05/soap-envelope/",
    "soap:encodingStyle", "http://www.w3.org/2003/05/soap-encoding",
    modeCaseSensitive)
  result.attrs = attrs

proc body* (self: var SoapEncoder): XmlNode =
  ## Creates a SOAP body.
  result = new_element("soap:Body")

proc add_body_namespaces* (self: var SoapEncoder; body: var XmlNode) =
  ## Adds namespace tags to the supplied SOAP body. Use
  ## after creating a body, encoding children to it, so that
  ## the namespace attributes are properly added.
  # TODO

proc associate_namespace*(self: var SoapEncoder;
                          name, uri: string): string =
  ## Informs the encoder that you need a namespace
  ## prefix. You would prefer `name` which points at `uri`,
  ## and you will be told what namespace prefix to use. You
  ## will *usually* get the name you want, unless the `uri`
  ## is already registered (in which case you will get the
  ## first name to use that uri.)

  # TODO
  return name

type
  ManuallySerialized* {.xmlns("bagel", "null://burger").} = object
    foo* {.xmlkey: "foo".}, bar* {.xmlkey: "bar".}: string

# this is the example function for when you need to manually
# encode stuff; we will be generating this via macros
proc soap_encode(self: ManuallySerialized;
                 container: XmlNode;
                 encoder: var SoapEncoder): XmlNode =
  let ns = encoder.associate_namespace("bagel", "null://burger")
  if container != nil:
    result = container
  else:
    result = new_element(ns & ":ManuallySerialized")

  var foo = new_element(ns & ":foo")
  foo.add new_text(escape(self.foo))
  result.add(foo)

  var bar = new_element(ns & ":bar")
  bar.add new_text(escape(self.bar))
  result.add(bar)

var encoder = SoapEncoder()
var soap = encoder.envelope()
var bod = encoder.body()
soap.add bod
let ms = ManuallySerialized(foo: "hot diggity", bar: "slam doodly")
bod.add soap_encode(ms, nil, encoder)
encoder.add_body_namespaces(bod)
echo soap

