{
    "name": "Stock Picking Valued",
    "version": "19.0.0.0.0",
    "author": "Info'Lib",
    "website": "https://www.infolib.tn/",
    "category": "Sales/Sales",
    "description": """
    Valuation of the delivery note report according to the client
    """,
    "depends": ["sale_stock"],
    "data": [
        "views/stock_picking_views.xml",
        "views/res_partner_views.xml",
        "views/report_deliveryslip.xml",
    ],
    "license": "LGPL-3",
    "installable": True,
    "images": ["static/description/cover_540_270_stock_picking_valued.gif"],
}
