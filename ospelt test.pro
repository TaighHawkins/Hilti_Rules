
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - BELLOTTO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( bellotto, `7 March 2013` ).

i_date_format( _ ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	set(reverse_punctuation_in_numbers)

	, buyer_party( `LS` )

	, buyer_registration_number( `CH-ADAPTRI` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `CH-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`2100`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

%	, suppliers_code_for_buyer( `10535223` )
	, suppliers_code_for_buyer( `10402444` )

%	, customer_comments( `Customer Comments` )
%	, or( [ [ q0n(line), customer_comments_line ] , customer_comments( `` ) ])

	, customer_comments( `` )

%	, shipping_instructions( `Shipping Instructions` )
	, shipping_instructions( `` )

	,[q0n(line), get_order_number ]

	,[q0n(line),  get_order_date ]

	,[q0n(line), get_buyer_contact ]

	%,[q0n(line), get_buyer_ddi ]

	,[q0n(line), get_buyer_email ]

	,[ q0n(line), get_line_order_date ]
	
	,[ q0n(line), get_delivery_party ]

	,[ q0n(line), get_delivery_street ]

	,[ q0n(line), get_delivery_city ]

	,[ q0n(line), get_delivery_postcode ]

	, get_line_items

	, total_net(`0`), total_invoice(`0`)

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_delivery_party, [
%=======================================================================
 
	 `<`, `ADR`, `_`, `Firma`, `>`

	, delivery_party(s)

	, `<`, `/`, `ADR`, `_`, `Firma`, `>`,  newline

	, trace([ `delivery party`, delivery_party ])

] ).

%=======================================================================
i_line_rule( get_delivery_street, [ 
%=======================================================================

	`<`, `ADR`, `_`, `ADR1`, `>`

	, delivery_street(s)

	, `<`, `/`, `ADR`, `_`, `ADR1`, `>`,  newline

	, trace([ `delivery street`, delivery_street ])
	

]).

%=======================================================================
i_line_rule( get_delivery_city, [ 
%=======================================================================

	`<`, `ADR`, `_`, `Ort`, `>`	

	, delivery_city(s)

	, `<`, `/`, `ADR`, `_`, `Ort`, `>`,  newline

	, trace([ `delivery city`, delivery_city ])

	

]).

%=======================================================================
i_line_rule( get_delivery_postcode, [ 
%=======================================================================

	`<`, `ADR`, `_`, `PLZ`, `>`

	, delivery_postcode(s)

	, `<`, `/`, `ADR`, `_`, `PLZ`, `>`,  newline

	, trace([ `delivery postcode`, delivery_postcode ])

	

]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_order_date, [ 
%=======================================================================

	`<`, `Datum`, `>`
	
	, invoice_date(date)

	, `<`, `/`, `Datum`, `>`,  newline

	, trace( [ `invoice date`, invoice_date] )

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_order_number, [ 
%=======================================================================

	q0n(anything)

	,`<`, `Prozess`, `ID`, `_`, `Auftrag`, `=`, `"`

	, order_number(s)

	, `"`, `Dat`, `_`, `Erstellung`

	, trace([ `order number`, order_number ])



] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_buyer_contact, [ 
%=======================================================================

	`<`, `Name`, `>`

	, buyer_contact(s), `<`, `/`, `Name`, `>`,  newline

	, trace([ `buyer contact`, buyer_contact ])

] ).

%=======================================================================
i_line_rule( get_buyer_ddi, [ 
%=======================================================================

	`<`, `ADR`, `_`, `Tel`, `>`

	, buyer_ddi(s)

	, `<`, `/`, `ADR`, `_`, `Tel`, `>`,  newline

	, trace([ `buyer ddi`, buyer_ddi ])

] ).

%=======================================================================
i_line_rule( get_buyer_email, [ 
%=======================================================================

	`<`, `Email`, `>`

	, buyer_email(s)

	, `<`, `/`, `Email`, `>`,  newline

	, trace([ `buyer email`, buyer_email ])

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_line_items, [
%=======================================================================

	get_line_item

	, q0n( line )

	, get_line_descr

	, get_line_quantity

	, q0n( line )

	, get_line_original_order_date
] ).

%=======================================================================
i_line_rule( get_line_item, [ 
%=======================================================================

	`<`, `Artikel`, `Art`, `_`, `Nr`, `_`, `Anbieter`, `=`, `"`

	, line_item(w)

	, `"`, `>`,  newline

	, trace([ `line item`, line_item ])

] ).

%=======================================================================
i_line_rule( get_line_descr, [ 
%=======================================================================

	`<`, `Art`, `_`, `Txt`, `_`, `Kurz`, `>`

	, line_descr(s)

	, `<`, `/`, `Art`, `_`, `Txt`, `_`, `Kurz`, `>`,  newline

	, trace([ `line descr`, line_descr ])

] ).

%=======================================================================
i_line_rule( get_line_quantity, [ 
%=======================================================================

	`<`, `Art`, `_`, `Menge`, `>`

	, line_quantity(d)

	, `<`, `/`, `Art`, `_`, `Menge`, `>`,  newline

	, trace([ `line quantity`, line_quantity ])

] ).


%=======================================================================
i_line_rule( get_line_original_order_date, [ 
%=======================================================================

	`<`, `LiefDat`, `_`, `Kundenwunsch`, `>`

	, line_original_order_date(date)

	, `<`, `/`, `LiefDat`, `_`, `Kundenwunsch`, `>`,  newline

	, trace([ `line original order date`, line_original_order_date ])

] ).
