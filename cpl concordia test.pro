%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - CPL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( cpl, `13 May 2013` ).

i_date_format( _ ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	set(reverse_punctuation_in_numbers)

	, buyer_party( `LS` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `IT-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`7500`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

%	, suppliers_code_for_buyer( `12967770` )     %PROD
	, suppliers_code_for_buyer( `10658906` )     %TEST

%	, customer_comments( `Customer Comments` )
	, [ q0n(line), customer_comments_line ]

%	, shipping_instructions( `Shipping Instructions` )
	, [ q0n(line), shipping_instructions_line ]

	,[q0n(line), get_delivery_address ]

	,[q0n(line), get_order_number ]

	,[q0n(line), get_order_date ]

	,[q0n(line), get_buyer_contact ]

	, get_invoice_lines

	,[ q0n(line), get_invoice_total_number]

	, replicate_address


] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%=======================================================================
i_line_rule( customer_comments_line, [
%=======================================================================
 
	`Condizioni`, `di`, `consegna`, tab

	, customer_comments(s)

	, trace([ `customer comments`, customer_comments ])

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SHIPPING INSTRUCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%=======================================================================
i_line_rule( shipping_instructions_line, [
%=======================================================================
 
	`Condizioni`, `di`, `consegna`, tab

	, shipping_instructions(s)

	, trace([ `shipping instructions`, shipping_instructions ])

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================
 
	delivery_header_line

	, q10([ delivery_party_line, q10(get_delivery_address_line) ])

	, delivery_street_line

	, delivery_postcode_and_city

] ).

%=======================================================================
i_line_rule( delivery_header_line, [ 
%=======================================================================

	`indirizzo`, `di`, `spedizione`

	, q10(tab)

	, delivery_party(s)

	, trace([ `delivery header found` ])
	

]).


%=======================================================================
i_line_rule( delivery_party_line, [ 
%=======================================================================

	delivery_party(s), newline

	, trace([ `delivery party`, delivery_party ])
	

]).

%=======================================================================
i_line_rule( get_delivery_address_line, [
%=======================================================================
 
	delivery_address_line(s)

	, trace([ `delivery address line`, delivery_address_line ])

] ).


%=======================================================================
i_line_rule( delivery_street_line, [ 
%=======================================================================
	
	delivery_street(s), newline

	, trace([ `delivery street`, delivery_street ])
	

]).

%=======================================================================
i_line_rule( delivery_postcode_and_city, [ 
%=======================================================================

	postc(w), `-`

	, delivery_postcode(d)

	, trace([ `delivery postcode`, delivery_postcode ])

	, delivery_city(s)

	, trace([ `delivery city`, delivery_city ])

	, delivery_state(w)

	, trace([ `delivery state`, delivery_state ])

	, newline

	

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_order_date, [ 
%=======================================================================


	`data`, tab

	, invoice_date(date)

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

	, `numero`, `documento`, tab

	, order_number(s)

	, trace( [ `order number`, order_number ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_buyer_contact, [ 
%=======================================================================

	`Acquirente`, tab

	, buyer_contact(s)

	, trace([ `buyer contact`, buyer_contact ])


] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_total_number, [
%=======================================================================

	invoice_total_number_header

	, q(0, 5, line), get_invoice_total_number_line

] ).

%=======================================================================
i_line_rule( invoice_total_number_header, [
%=======================================================================

	q0n(anything)

	,`Totale`

	, newline

	, trace( [ `total invoice header found` ] )	

] ).

%=======================================================================
i_line_rule( get_invoice_total_number_line, [
%=======================================================================

	q0n(anything)

	, read_ahead(total_invoice(d))

	, total_net(d)

	, `eur`

	, newline

	, trace( [ `total invoice`, total_invoice ] )	

	, trace( [ `total net`, total_net ] )	

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	line_header_line

	, qn0( [ peek_fails(line_end_line)

		, or([ [line_invoice_line, q10(get_item_code_line)], line ])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ 
%=======================================================================

	`Pos`, `.`, `Materiale`, tab, `Descrizione`

] ).

%=======================================================================
i_line_rule_cut( line_end_line, [ 
%=======================================================================

	or([ [`L`, `'`, `ordine`, `è`, `da`, `intendersi`, `accettato`]

	, [`addetto`, `emissione`, `ordine`] ])

] ).

%=======================================================================
i_rule_cut( get_item_code_line, [
%=======================================================================

	q(0, 5, line)

	, peek_fails(line_invoice_line), peek_fails(line_end_line)

	,  item_code_line

] ).


%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================
	 
	line_no(d)

	, or([line_item_for_buyer(w), line_item_for_buyer(``) ]), tab

	, trace( [ `line item for buyer`, line_item_for_buyer] )	

	, line_descr(s), tab

	, trace( [ `line descr`, line_descr ] )	

	, line_quantity(d)

	, trace( [ `line quantity`, line_quantity ] )	

	, line_quantity_uom_code(w)

	, q0n(anything)

	, tab, line_net_amount(d), tab

	, trace( [ `line net amount`, line_net_amount ] )

	, line_original_order_date(date)

	, trace( [ `line original order date`, line_original_order_date ] )

	, newline

		
] ).


%=======================================================================
i_line_rule_cut( item_code_line, [
%=======================================================================

	or([ [`Vostro`, `numero`, `materiale`, `:`], [`cod`, `.` ], [ `CODICE`, `ARTICOLO`, `:`]  ])

	, line_item(s)

	, trace( [ `line item`, line_item ] )

] ).

%=======================================================================
i_line_rule_cut( item_code_line, [
%=======================================================================

	dummy(w), check(dummy(start) > -350), check(dummy(start) < -300)
	
	, q0n(word)

	, line_item( f([ begin, q(dec,5,8), end ]) )

	, newline

	, trace( [ `line item`, line_item ] )

] ).



%=======================================================================
i_rule( replicate_address, [
%=======================================================================

	q10([ with(invoice, buyer_contact, BC), delivery_contact(BC) ])

	, q10([ with(invoice, buyer_email, BE), delivery_email(BE) ])

	, q10([ with(invoice, buyer_ddi, BI), delivery_ddi(BI) ])

	, q10([ with(invoice, buyer_fax, BF), delivery_ddi(BF) ])


] ).





