%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - INTERSERVE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( interserve, `19 September 2014` ).

i_date_format( _ ).

i_orders05_idocs_e1edkt1( `Z011`, picking_instructions ).
i_orders05_idocs_e1edkt1( `Z012`, packing_instructions ).

i_user_field( invoice, picking_instructions, `Picking Instructions` ).
i_user_field( invoice, packing_instructions, `Packing Instructions` ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	buyer_party( `LS` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `GB-INTERSV` )

	, supplier_registration_number( `P11_100` )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`4400`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)


	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `10585780` ) ]    %TEST
	    , suppliers_code_for_buyer( `12224307` )                      %PROD
	]) ]

%	, customer_comments( `Customer Comments` )
	, [ q0n(line), customer_comments_line ]

%	, shipping_instructions( `Shipping Instructions` )
	, [ q0n(line), shipping_instructions_line ]


	, [ q0n(line), get_invoice_type ]

	,[q0n(line), get_delivery_details ]

	,[q0n(line), get_delivery_location ]

	,[q0n(line), get_order_number ]

	,[q0n(line), get_order_date ]

	, get_buyer_contact

%	,[q0n(line), get_buyer_ddi ]

%	,[q0n(line), get_buyer_fax ]

	, buyer_ddi(`01215005000`)

	, buyer_fax(`01215255574`)

	,[ q0n(line), get_general_original_order_date]

	, get_invoice_lines

	,[ q0n(line), get_invoice_total_number]


] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TYPE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_invoice_type, [ 
%=======================================================================

	q0n(anything)

	, or([ `engrave`, `engraved` ])

	, invoice_type(`ZE`)

] ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENERAL ORIGINAL ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_general_original_order_date, [ 
%=======================================================================

	q0n(anything)

	, `Delivery`, `date`, `.`, `.`, `.`, `.`, `:`

	, due_date(date)

]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%=======================================================================
i_line_rule( customer_comments_line, [
%=======================================================================
 
	`order`, `no`, `.`, any(s), tab

	, customer_comments(s1)

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
 
	`order`, `no`, `.`, any(s), tab

	, shipping_instructions(s1)

	, trace([ `shipping instructions`, shipping_instructions ])


] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Delivery ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule( get_delivery_details, [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	gen1_address_details_without_names( [ delivery_left_margin, delivery_start_rule,
					delivery_street, delivery_address_line, delivery_city, delivery_state_x, delivery_postcode,
					delivery_end_line ] )


] ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule( delivery_start_rule, [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	 get_delivery_start_line

	, delivery_first_line
	

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_line_rule( get_delivery_start_line, [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	 q0n(anything)

	, read_ahead( delivery_left_margin )

	, `delivery`, `address`, newline

	, check( i_user_check( gen1_store_address_margin( delivery_left_margin ), delivery_left_margin(start), 10, 10 ) )
	

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_line_rule( delivery_first_line, [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	 q0n(anything)

	, delivery_party(s)

	, newline

	, check(delivery_party(start) > 0 )



] ).


%=======================================================================
i_line_rule( delivery_end_line, [ 
%=======================================================================

	or( [with(delivery_postcode)

	, [`delivery`, `date`, `.` ] ])


] ).

%=======================================================================
i_line_rule( get_delivery_location, [
%=======================================================================
 
	q0n(anything)

	, `cost`, `centre`, `:`

	, delivery_location(w), `/`, dum(w)

	, trace([ `delivery location`, delivery_location ])

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

	,`date`, q10( `.` ), `:`

	, invoice_date(date)

	, newline

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

	 `order`, `no`, `.`

	, order_number(s)

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

	q0n(line), generic_horizontal_details( [ [ at_start, `Name`, qn1( `.` ), `:` ], buyer_contact_x, s1 ] )
	
	, check( i_user_check( reverse_names, buyer_contact_x, Con ) )

	, buyer_contact( Con )

	, delivery_contact( Con )
	
	, check( string_string_replace( Con, ` `, `.`, Email_Name ) )
	, check( strcat_list( [ Email_Name, `@interserve.com` ], Email ) )
	
	, buyer_email( Email )
	, delivery_email( Email )

] ).

%=======================================================================
i_user_check( reverse_names, Names_In, Names_Out ):- 
%=======================================================================
  
	  strip_string2_from_string1( Names_In, `,`, Names_In_Strip )  
	, sys_string_split( Names_In_Strip, ` `, Names_Rev ) 
	, sys_reverse( Names_Rev, Names )

	, wordcat( Names, Names_Out )
.

%=======================================================================
i_line_rule( get_buyer_ddi, [ 
%=======================================================================

	`Telephone`, `.`, `.`, `:`

	, buyer_ddi(d), append(buyer_ddi(d), ``, ``)

	, trace([ `buyer ddi`, buyer_ddi ])


] ).

%=======================================================================
i_line_rule( get_buyer_fax, [ 
%=======================================================================

	`Fax`, `.`, `.`, `.`, `.`, `.`, `.`, `.`, `.`, `.`, `.`, `.`, `.`, `.`, `:`

	, buyer_fax(d), append(buyer_fax(d), ``, ``)

	, trace([ `buyer fax`, buyer_fax ])


] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_invoice_total_number, [
%=======================================================================

	`total`, `:`, tab		

	, read_ahead(total_invoice(d))

	, total_net(d)

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

		, or([ get_line_invoice, quotation_line, line_continuation_line, line ])

		] )

] ).


%=======================================================================
i_line_rule( line_continuation_line, [ 
%=======================================================================

	read_ahead( continue(s1) ), check(continue(end) < 100 )

	, append(line_descr(s1), ` `, ``)

	, newline

]).


%=======================================================================
i_rule_cut( quotation_line, [ 
%=======================================================================

	quotation_line_invoice

	, item_code_line


] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ 
%=======================================================================

	`Quantity`, `Description`, tab, `Unit`

] ).

%=======================================================================
i_line_rule_cut( line_end_line, [ 
%=======================================================================

	or([ [`total`, `:`, tab] , [`this`, `purchase`, `order` ], [`registered`, `office` ] ])

] ).


%=======================================================================
i_line_rule_cut( quotation_line_invoice, [
%=======================================================================
	 
	line_quantity(d)

	, trace( [ `line quantity`, line_quantity ] )

	, `quotation`

	, line_quotation(s1), tab

	, trace( [ `line item`, line_item ] )

	, unitprice(d), tab
	
	, priceunit(d), tab

	, q10([disc(d), tab])

	, line_net_amount(d)

	, trace( [ `line net amount`, line_net_amount ] )

	, with( invoice, due_date, DATE )

	, line_original_order_date( DATE )

	, trace( [ `original order date set to`, line_original_order_date ] )

	, newline

		
] ).


%=======================================================================
i_line_rule_cut( item_code_line, [ 
%=======================================================================

	or([ line_item(d), line_item(`missing`) ])

	, line_descr(s1), newline


] ).


%=======================================================================
i_line_rule_cut( line_check_line, [ q(3,3, [ q0n(anything), num(d), tab ] ) ] ).
%=======================================================================
i_rule_cut( get_line_invoice, [
%=======================================================================
	 
	get_line_invoice_line
	
	, q10( [ read_ahead( generic_line( [ check_text( `engrave` ) ] ) )
	
		, peek_ahead( gen_count_lines( [ or( [ line_check_line, line_end_line ] ), Count ] ) )
		
		, generic_line( Count, -500, 250, [ generic_item( [ picking_instructions_x, s1 ] )  ] )
		
		, check( picking_instructions_x = Pick_x )
		, check( line_descr = Descr )
		
		, check( strcat_list( [ Descr, `
`, Pick_x ], Pick ) )

		, or( [ [ without( picking_instructions )
		
				, picking_instructions( Pick )
				, packing_instructions( Pick )
				
			]
			
			, [ with( picking_instructions )
			
				, append( picking_instructions( Pick ), `
`, `` )
				, append( packing_instructions( Pick ), `
`,	``)

			]
			
		] )
		
	] )
	
] ).

%=======================================================================
i_line_rule_cut( get_line_invoice_line, [
%=======================================================================
	 
	line_quantity( fd( [ begin, q(dec,0,3), q(other(","),0,1),  q(dec,1,3), q(other("."),1,1), q(dec("0"),4,4), end ]) ) 

	%line_quantity(d)

	, trace( [ `line quantity`, line_quantity ] )

	, peek_fails(`Quotation`)
	
	% , or([ line_item(d), line_item(`285780`) ])

	 , or([ line_item(d), line_item(`missing`) ])

	, trace( [ `line item`, line_item ] )

	, or([ line_descr(s1), line_descr(` `) ]), tab

	, trace( [ `line descr`, line_descr ] )	

	, unitprice(d), tab
	
	, priceunit(d), tab

	, q10([disc(d), tab])

	, line_net_amount(d)

	, trace( [ `line net amount`, line_net_amount ] )

	, with( invoice, due_date, DATE )

	, line_original_order_date( DATE )

	, trace( [ `original order date set to`, line_original_order_date ] )

	, newline

		
] ).

