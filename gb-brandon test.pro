%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - BRANDON
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( brandon, `12 February 2013` ).

i_date_format( _ ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	 buyer_party( `LS` )

%	, buyer_registration_number( `Customer` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `GB-BRANDON` )

	, supplier_registration_number( `P11_100` )

	, currency( `4400` )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`4400`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, suppliers_code_for_buyer( `10585780` )
%	, suppliers_code_for_buyer( `12237096` )

	, invoice_type(``)

	, customer_comments(``)

%	, customer_comments( `Customer Comments` )
%	, or( [ [ q0n(line), customer_comments_line ] , customer_comments( `` ) ])

%	, shipping_instructions( `Shipping Instructions` )
	, shipping_instructions( `` )

	, delivery_party(`BRANDON HIRE LIMITED`) 

	, buyer_ddi(`01179719119`)

	, buyer_email(``)

	, delivery_ddi(`01179719119`)

	, delivery_email(``)

	, get_delivery_details

	,[q0n(line), get_order_number ]

	,[q0n(line), get_order_date ]
 
	,[q0n(line), get_buyer_contact ]

	,[q0n(line), original_order_date_line ]

	, get_invoice_lines

	,[ q0n(line), get_net_total_number]

	,[ q0n(line), get_invoice_total_number]

	,[q0n(line), get_delivery_contact ]

	,[q0n(line), get_delivery_location ]



] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORIGINAL ORDER DATE LINE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( original_order_date_line, [ 
%=======================================================================


	 q0n(anything)

	, `required`, `by`

	, line_original_order_date(date)

	, trace( [ `line original order date`, line_original_order_date] )

]).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Delivery ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule( get_delivery_details, [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	gen1_address_details_without_names( [ delivery_left_margin, delivery_start_line,
					delivery_street, delivery_address_line_a, delivery_city, delivery_state_a, delivery_postcode,
					delivery_end_line ] )

	, delivery_dept(``)


] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_line_rule( delivery_start_line, [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	 `deliver`, `to`, `:`

	, delivery_left_margin

	, check( i_user_check( gen1_store_address_margin( delivery_left_margin ), delivery_left_margin(start), 5, 10 ) )

] ).



%=======================================================================
i_line_rule( delivery_end_line, [ 
%=======================================================================

	or( [with(delivery_postcode)

	, [`contact`, `:`] ])


] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_order_date, [ 
%=======================================================================


	 q0n(anything)

	, `Date`, `:`

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

	`Purchase`, tab, `Order`, `:`, tab

	, order_number(s)

	, newline

	, trace( [ `order number`, order_number ] ) 


] ).




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_delivery_contact, [ 
%=======================================================================


	`contact`, `:`

	, or([ [ delivery_contact(s), `(` ], [ delivery_contact(s) , newline ] ])

	, trace([ `delivery contact`, delivery_contact ])

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_buyer_contact, [ 
%=======================================================================

	q0n(anything)

	,`written`, `by`, `:`

	, buyer_contact(s)

	, newline

	, trace([ `buyer contact`, buyer_contact ])

] ).

%=======================================================================
i_line_rule( get_delivery_location, [ 
%=======================================================================

	`deliver`, `to`, `:`

	, q0n(word), delivery_location(w), `)`

	, trace([ `delivery location`, delivery_location ])

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_net_total_number, [
%=======================================================================

	 q0n(anything)

	, `goods`, tab

	, total_net(d)

	, newline

	, trace( [ `total net`, total_net ] )

] ).

%=======================================================================
i_line_rule( get_invoice_total_number, [
%=======================================================================

	q0n(anything)

	, `total`, tab

	, total_invoice(d)

	, newline

	, trace( [ `total invoice`, total_invoice ] )	

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

		, or([ get_line_invoice, line ])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ 
%=======================================================================

	
   `deliver`, `to`, `:`



] ).


%=======================================================================
i_line_rule_cut( line_end_line, [ 
%=======================================================================

	
	 `*`, `*`, `PLEASE`, `ENCLOSE`, `A`, `DELIVERY`

] ).

%=======================================================================
i_line_rule_cut( get_line_invoice, [
%=======================================================================

	or([

	[ item_code(s), tab, read_ahead([ q0n(word), line_item( f( [ begin, q(dec,5, 9), end ]) ) ]) ]

	, [ line_item( f( [ begin, q(dec,5, 9), end ]) ),  tab ]

	, [ line_item(s), tab ]

	])

	, trace( [ `line item`, line_item ] )	

	, line_descr(s), tab

	, trace( [ `line descr`, line_descr ] )	

	, line_quantity(d)

	, trace( [ `line quantity`, line_quantity ] )

	, or([ [`each`, line_quantity_uom_code(`PC`) ]

	, [ `box`, line_quantity_uom_code(`PK`) ]  ])

	, tab

	, trace( [ `line quantity uom code`, line_quantity_uom_code ] )	

	, line_unit_amount(d), each(w), tab

	, trace( [ `line unit amount`, line_unit_amount ] )	

	, line_net_amount(d)

	, trace( [ `line net amount`, line_net_amount ] )

	, vat(w)

	, newline

		


] ).

%=======================================================================
i_line_rule_cut( line_continuation_line, [
%=======================================================================

	append( line_descr(s), ` `, ``) , newline

] ).


