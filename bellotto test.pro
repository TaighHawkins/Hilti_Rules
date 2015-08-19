%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - BELLOTTO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( bellotto, `13 February 2013` ).

i_date_format( _ ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	set(reverse_punctuation_in_numbers)

	, buyer_party( `LS` )

%	, buyer_registration_number( `Customer` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `IT-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`7500`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

%	, suppliers_code_for_buyer( `13152296` ) % PROD
	, suppliers_code_for_buyer( `10671869` ) % TEST

%	, customer_comments( `Customer Comments` )
%	, or( [ [ q0n(line), customer_comments_line ] , customer_comments( `` ) ])

	, customer_comments( `` )

%	, shipping_instructions( `Shipping Instructions` )
	, shipping_instructions( `` )

	,[q0n(line), get_delivery_address ]

	,[q0n(line), get_order_number ]

	,[q0n(line),  get_order_date ]

	%,[q0n(line), get_buyer_contact ]

	,[ q0n(line), get_original_order_date([DATE]) ]

	, get_invoice_lines([DATE])

	,[ q0n(line), get_net_total_number]

	,[ q0n(line), get_invoice_total_number]
	
	,[ q0n(line), get_delivery_party ]


] ).



%=======================================================================
i_line_rule( get_original_order_date([DATE]), [ 
%=======================================================================

	`consegna`, tab, original_order_date(date)

	, check( i_user_check( gen_same, original_order_date, DATE ) )


] ).




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_delivery_party, [
%=======================================================================
 
	 `CANTIERE`, `:`

	, dateref(s), tab

	, delivery_party(s)

	, trace([ `delivery party`, delivery_party ])

	, check(delivery_party(start) > -145 )

	, check(delivery_party(end) < 110 )

	, newline 

	 
] ).


%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================
 
	  

	 delivery_header_line

	 , q(0,2,line)

	 , delivery_party_line

 	, q(0,2,line)

	 , delivery_street_line

	 , q(0,2,line)

	 , delivery_postcode_and_city

] ).

%=======================================================================
i_line_rule( delivery_header_line, [ 
%=======================================================================

	`Indirizzo`, `destinazione`, `del`, `materiale`,  newline

	, trace([ `delivery header found` ])
	

]).

%=======================================================================
i_line_rule( delivery_party_line, [ 
%=======================================================================
	
	delivery_party(s)

	, check(delivery_party(start) > -140 )

	, check(delivery_party(end) < 100 )

	, trace([ `delivery party`, delivery_party ])

	, newline
	

]).

%=======================================================================
i_line_rule( delivery_street_line, [ 
%=======================================================================

	delivery_street(s)

	, check(delivery_street(start) > -140 )

	, check(delivery_street(end) < 100 )

	, trace([ `delivery street`, delivery_street ])

	, newline
	

]).

%=======================================================================
i_line_rule( delivery_postcode_and_city, [ 
%=======================================================================

	delivery_postcode(d), `-`

	, check(delivery_postcode(start) > -140 )

	, check(delivery_postcode(end) < 100 )

	, trace([ `delivery postcode`, delivery_postcode ])

	, delivery_city(s)

	, check(delivery_city(start) > -140 )

	, check(delivery_city(end) < 100 )

	, trace([ `delivery city`, delivery_city ])

	, `(`, delivery_state(w), `)`

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

	`CONCORDIA`, `SAGITTARIA`, `li`, `,`
	
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

	`ORDINE`, `N`, `°`

	, order_number(s), `da`

	, trace( [ `order number`, order_number ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	  buyer_contact_header_line

	, q(0, 2, line), get_buyer_contact_line

] ).

%=======================================================================
i_line_rule( buyer_contact_header_line, [ 
%=======================================================================

	q0n(anything)

	, `da`, `:`, tab, `a`, `:`

	, trace([ `buyer contact header found` ])

] ).

%=======================================================================
i_line_rule( get_buyer_contact_line, [ 
%=======================================================================

	buyer_contact(s), tab

	, check(buyer_contact(end) < -280 )

	, trace([ `buyer contact`, buyer_contact ])

	, check( i_user_check( gen_string_to_upper, buyer_contact, CU  ) )

	, buyer_contact( CU )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_net_total_number, [
%=======================================================================

	 

	`Totale`, `Ordine`, `oltre`, `I`, `.`, `V`, `.`, `A`, `.`, tab

	, total_net(d)

	, newline

	, trace( [ `total net`, total_net ] )

] ).

%=======================================================================
i_line_rule( get_invoice_total_number, [
%=======================================================================

	`Totale`, `Ordine`, `oltre`, `I`, `.`, `V`, `.`, `A`, `.`, tab

	, total_invoice(d)

	, newline

	, trace( [ `total invoice`, total_invoice ] )	

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_lines([DATE]), [
%=======================================================================

	 q0n(line)

	, line_header_line

	, qn0( [ peek_fails(line_end_line)

		, or([ get_invoice_line([DATE]), line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `(`, `in`, `)`, tab, `(`, `in`, `)`,  newline ] ).
%=======================================================================


%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	`Totale`, `Ordine`, `oltre`, `I`, `.`, `V`, `.`, `A`, `.`, tab

	] ).

%=======================================================================
i_line_rule_cut( get_invoice_line([DATE]), [
%=======================================================================

	trace([ `start line rule` ])

	, line_original_order_date(DATE)	

	, trace([ `lood` , line_original_order_date])

	, line_item(s), tab

	, trace([`line item`, line_item])

	, line_descr(s), tab

	, trace([`line descr`, line_descr])

	, line_quantity_uom_code(w), tab

	, trace([`line quantity uom code`, line_quanity_uom_code])

	, line_quantity(d), tab

	, trace([`line quantity`, line_quantity])

	, line_unit_amount(d), tab

	, trace([`line unit amount`, line_unit_amount])

	, line_net_amount(d)

	, trace([`line net amount`, line_net_amount])

	, newline


] ).


%=======================================================================
i_rule_cut( decode_line_uom_code, [
%=======================================================================

	or([ [ `pz`, line_quantity_uom_code( `EA` ) ]

		, [ `cf`, line_quantity_uom_code( `EA` ) ]

		, [ `m`, line_quantity_uom_code( `M` ) ]

		, [ `mt`, line_quantity_uom_code( `M` ) ]

		, [ `ml`, line_quantity_uom_code( `M` ) ]

		, [ word ]

	])

] ).

