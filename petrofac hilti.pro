%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - PETROFAC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( petrofac, `23 January 2015` ).

i_date_format( _ ).

i_user_field( invoice, quotation_number, `Quotation Number` ).
i_op_param( custom_e1edk02_segments, _, _, _, `true` ).
custom_e1edk02_segment( `004`, quotation_number ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_quotation_number

	, get_order_number
	
	, get_fixed_variables
	
	, get_delivery_date
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QUOTATION NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_quotation_number, [
%=======================================================================

	q0n(line)
	
	, generic_horizontal_details( [ 
		[ at_start
			, or( [ [ `Quotation`, `No`, `:` ]
			
				, [ `Quote`, `Ref`, `:` ]
			
				, [ `Reference`, `is`, `made`, `to`, `quotation` ]
			
			] ) 
		]
		
		, quotation_number, sf
		
		, or( [ `,`, `dated`, tab, newline ] )
		
	] )
	
	, trace( [ `Processed as a quote` ] )
	, set( processed_quote )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_delivery_details

	, get_invoice_date
	
	, get_customer_comments

	, get_buyer_contact

	, get_invoice_lines

	, get_totals

	, set_buyer_email
	

] ):- not( grammar_set( processed_quote ) ).


%=======================================================================
i_rule( set_buyer_email, [ buyer_email(FROM) ]) :- i_mail(from, FROM).
%=======================================================================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIXED VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [ 
%=======================================================================

	  buyer_party( `LS` )

	, supplier_party( `LS` )

	, buyer_registration_number( `GB-PETROFA` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`4400`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, invoice_type( `02` )

	, suppliers_code_for_buyer( `12232481` )
	
	, q10( [ with( quotation_number ), delivery_note_number( `12345676` ) ] )
	
	, q10( [ with( quotation_number ), with( order_number ), force_result( `success` ) ] )
	
	, q10( [ without( quotation_number )
	
		, delivery_party( `PETROFAC FACILITIES MANAGEMENT LTD` )
	
		, buyer_ddi( `01224 247000` )

		, type_of_supply(`G2`)
	
		, buyer_fax( `01224 256001` )
	] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ q( 0, 5, line ), generic_horizontal_details( [ [ `PURCHASE`,`ORDER` ], 150, order_number, s1, newline ] ) ] ).
%=======================================================================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE DATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_date, [ q( 0, 15, line ), generic_horizontal_details( [ [ `ORDER`, `DATE` ], 150, invoice_date, date, newline ] ) ] ).
%=======================================================================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( delivery_details_header, [ q0n(anything), read_ahead( [ `Ship`, `To` ] ), delivery_hook(sf), `:`, delivery_street(s), `,` ] ).
%=======================================================================
i_rule( get_delivery_details, [
%=======================================================================

	  q(0,20, line ), delivery_details_header
	  
	, q10( delivery_detail( [ delivery_dept, s ] ) )
	
	, q10( delivery_detail( [ delivery_street, s ] ) )

	, delivery_detail( [ delivery_city, s ] )
	
	, q01( line )
	
	, delivery_detail( [ delivery_postcode, pc ] )

] ).

%=======================================================================
i_rule( delivery_detail( [ Variable, Parameter ] ), [ q10( line_on_right ), delivery_detail_line( [ Variable, Parameter ] ) ] ).
%=======================================================================
i_line_rule_cut( delivery_detail_line( [ Variable, Parameter ] ), [ 
%=======================================================================

	  q0n(anything), Read_Var

	, `,` 
	
	, check( Check_Var > delivery_hook(end) )
	
	, check( Check_Var < 200 )
	  
	, trace( [ String, Variable ] ) 
	  
] )
:-
	  Read_Var =.. [ Variable, Parameter ]
	  
	, Check_Var =.. [ Variable, start ]
	
	, sys_string_atom( String, Variable )
	
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [
%=======================================================================

	  q(0,20,line), generic_horizontal_details( [ [ `CREATED`, `BY` ], 350, buyer_contact, s1, newline ] )
	  
	, check( string_string_replace( buyer_contact, ` `, `.`, Email ) )
	
	, trace( [ `stripped` ] )
	
	, wrap( buyer_email( Email ), ``, `@petrofac.com` )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( line_after_line, [ or( [ [ `Thru`, `ex`, `VAT` ], [ `Requisition`, `No` ] ] ) ] ).
%=======================================================================
i_rule( get_customer_comments, [
%=======================================================================

	  q(0,30,line), or( [ generic_horizontal_details( 2, -400, 0, [ [ read_ahead( [ `Final`, `Destination` ] ) ], customer_comments, s1, newline ] )
	  
		, generic_horizontal_details( 3, -400, 0, [ [ read_ahead( [ `Final`, `Destination` ] ) ], customer_comments, s1, newline ] )
	
	] )
	  
	, q(0,3,line), line_after_line

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  q0n(line), read_ahead( generic_horizontal_details( [ [ at_start, `Note`, q0n(anything), `Total` ], 100, net_subtotal_1, d, newline ] ) )
	  
	, check( net_subtotal_1 = Net )
	
	, gross_subtotal_1( Net )

] ).

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  q0n(line), read_ahead( generic_horizontal_details( [ [ `Total` ], 100, net_subtotal_1, d, newline ] ) )
	  
	, check( net_subtotal_1 = Net )
	
	, gross_subtotal_1( Net )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=======================================================================
i_section_control( get_invoice_lines, first_one_only ).
%=======================================================================
i_section_end( get_invoice_lines, line_end_section_line ).
%=======================================================================
i_line_rule_cut( line_end_section_line, [ `Petrofac`, `Facilities` ] ).
%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	 line_header_line

	, q0n( [

		  or( [ 

			line_carriage_line

			, line_invoice_rule

			, line

		] )

	] )
		
	, line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `DESCRIPTION`, newline ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ or( [ [ `PRICE`, `AND`, `DELIVERY` ], `DELIVERY` ] ) ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [ 
%=======================================================================

	  read_ahead( line_invoice_line )
	  
	, or( [ [ test( freight ), line ]
	
		, line_item_rule
	
		, [ line_item(`MISSING`), line ]

	] )
	
	, clear( freight )
	
] ).


%=======================================================================
i_rule( get_delivery_date, [ 
%=======================================================================
	  delivery_date( Later_string )
	, trace([ `delivery date`, delivery_date ])
] )
:-
	date_get( today, Today )
	, date_add( Today, days(14), Later )
	, date_string( Later, 'd/m/y', Later_string )
.



%=======================================================================
i_rule_cut( line_item_rule, [ 
%=======================================================================

	  q(0,4,line)
	  
	, or( [ [ test( got_item ), line, clear( got_item ) ]
	
		, line_item_line
	  
		, [ line
		
			, line_item_second_line
			
		]
		
	] ), trace( [ `line item`, line_item ] )
	
] ).

%=======================================================================
i_line_rule_cut( line_item_line, [ q0n(anything), or( [ `Item`, `(`, [`no`, `.`] ] ), line_item( f( [ begin, q(dec,4,10), end ] ) ) ] ).
%=======================================================================
i_line_rule_cut( line_item_line, [ q0n(anything), `-`, line_item( f( [ begin, q(dec,5,10), end ] ) ), gen_eof ] ).
%=======================================================================
i_line_rule_cut( line_word_item_line, [ q0n(anything), or( [ `Item`,  [`no`, `.`] ] )  ] ).
%=======================================================================
i_line_rule_cut( line_item_second_line, [ q0n(word), q10( `(` ), line_item( f( [ begin, q(dec,4,10), end ] ) ) ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ line_order_line_number, d, tab ] )
	
	, q10( [ read_ahead( [ q0n(word), generic_item( [ line_item, [ begin, q(dec,5,10), end ] ] ) ] ), set( got_item ) ] )
	
	, generic_item_cut( [ line_descr, s, [ q10( tab ), generic_item( [ line_original_order_date_x, date, tab ] ) ] ] )

	, q10([ with(invoice, delivery_date, DD), line_original_order_date(DD) ])
	
	, or( [ [ generic_item_cut( [ line_quantity, d, q10( tab ) ] )
	
			, generic_item_cut( [ line_quantity_uom_code, s1, q10( tab ) ] )
	
			, q01( [ `of`, tab ] )
	
			, generic_item( [ line_unit_amount, d, tab ] )
			
		]
		
		, [ set( freight )
		
			, line_item( `Missing` )
			
		]
		
	] )

	, generic_item( [ line_net_amount, d, newline ] )

] ).

%=======================================================================
i_line_rule_cut( line_carriage_line, [
%=======================================================================

	  q0n(anything)
	
	, or( [ `carriage`, `Freight`, `Delivery` ] )
	
	, qn0(anything)

	, tab, `10.00`

	, net_subtotal_3(`-10.00`), gross_subtotal_3(`-10.00`)

	, newline
	
	, trace([ `Carriage line` ])

] ).


