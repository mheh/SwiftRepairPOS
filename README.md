# SwiftRepairPOS
Open source Swift POS for repair shops, like computer stores. 
I've written 3 different code base attempts at this project. There seems to be nothing that does what I need it to do, so this is hopefully something that will help others too.

Architecture Design:
- Document: a model presentable to the frontend as an individual editable object (product, invoice, anything with a custom identifier: `PROD-1`)
- BaseDocument: a basic document containing line items (an invoice, quote, service order, purchase order)

## References
[vapor-auth-template](https://github.com/madsodgaard/vapor-auth-template)

