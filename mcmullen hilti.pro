%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - MCMULLEN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( mcmullen, `07 April 2015` ).

i_date_format( _ ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_delivery_location
	
	, get_order_number

	, get_invoice_date
	
	, get_due_date

	, get_buyer_ddi
	
	, get_buyer_fax
	
	, check( i_user_check( gen_cntr_set, 20, 0 ) )
	
	, get_invoice_lines

	, get_totals

	, [ q(0, 5, line), terms_line ]
	

] ).

%=======================================================================
i_line_rule( terms_line, [ 
%=======================================================================

	q0n(anything), `Conditions`,  `of`, `purchase`, newline

	, delivery_note_reference(`conditions`)

	, trace([ `terms amd conditions` ])
	
]).


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

	, buyer_registration_number( `GB-MCMULLF` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`4400`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, suppliers_code_for_buyer( `20511792` )
	
	, buyer_contact( `ELAINE MCCLOY` )
	
	, buyer_email( `ElaineM@mcmullenfacades.com` )
	, sender_name( `McMullen Facades Ltd.` )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY LOCATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_location, [ 
%=======================================================================

	q(0,40,line)
	
	, or( [ generic_horizontal_details( [ [ `Job`, `\\`, `Contract`,`No`, `.`, `:` ], delivery_location, d ] ) 
	
		, [ generic_horizontal_details( [ [ `Date`, tab, read_ahead( `Code` ), code(s1) ] ] )
			, generic_horizontal_details( [ tab, delivery_location, [ begin, q(dec,3,5), end ], check( delivery_location(start) > code(end) ) ] )
		]
	] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  or( [ [ q( 0, 5, line ), generic_horizontal_details( [ [ `Order`,`No`, `.` ], 150, order_number, s1, gen_eof ] )  ]
	  
		, [ q(0,10,line), order_number_header, q(2,2,up), q(0,4,line), order_number_line ]
		
	] )
	
	, q10( [ check( order_number = Ord )
		, check( string_to_lower( Ord, OrdL ) )
		, trace( [ `Checking for amendment` ] )
		, check( q_sys_sub_string( OrdL, _, _, `amendment` ) )
		, invoice_type( `ZE` )
		, trace( [ `ZE order` ] )
	] )
	
] ).

%=======================================================================
i_line_rule( order_number_header, [ q0n( [ dummy(s1), tab ] ), read_ahead( [ `Order`, or( [ [ `No`, `.` ], `Number` ] ) ] ), order_hook(s1) ] ).
%=======================================================================
i_line_rule( order_number_line, [ 
%=======================================================================

	  q0n(anything), order_number(s1), gen_eof
	  
	, check( order_number(start) = OrdStart )
	, check( order_number(end) = OrdEnd )
	
	, check( order_hook(start) = HookStart )
	, check( order_hook(end) = HookEnd )

	, or( [ [ check( sys_calculate( Diff, OrdStart - HookEnd ) )
			, check( Diff > 0 )	
			, check( Diff < 75 )
		]
		
		, [ check( i_user_check( approx_equal, HookStart, OrdStart, 10 ) )
			, check( i_user_check( approx_equal, OrdEnd, HookEnd, 25 ) )
			, check( OrdEnd > HookEnd )
		]
	] )
	
	, trace( [ `found order number`, order_number ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE DATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_date, [ 
%=======================================================================

	or( [ q(0,15,line)
	
		, [ q(0,25,line), generic_horizontal_details( [ [ `Date`, tab, `Code` ] ] )
		
			, set( alternate_date ), delivery_party( `McMullen Facades Ltd.` )
		]
	] )
	
	, invoice_date_line
	, clear( alternate_date )
	
] ).

%=======================================================================
i_line_rule( invoice_date_line, [
%=======================================================================

	  or( [ [ `Ship`, `-`, `to`, `Address`, tab ]
	  
		, test( alternate_date )
	] )
	
	, or( [ [ invoice_date(d), `.`
	
			, append( invoice_date(s1), ` `, `` )
		]
		
		, invoice_date( date )
	] )

	, trace( [ `invoice_date`, invoice_date ] )

	, q10( [ test( alternate_date )
		, qn0(anything), tab
		, or( [ [ due_date(d), `.`
				, append( due_date(s1), ` `, `` )
			]
			, due_date(date)	
		] )
		, trace( [ `Due Date`, due_date ] )
	] )

] ).

%=======================================================================
i_rule( get_due_date, [ without( due_date ), q( 0, 20, line ), due_date_line ] ).
%=======================================================================
i_line_rule( due_date_line, [ 
%=======================================================================

	  q0n(anything)
	  
	, `Delivery`, `Date`, `:`, tab
	
	, due_date(d), `.`
	
	, append( due_date(s1), ` `, `` )
	
	, trace( [ `due_date`, due_date ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACT NUMBERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_ddi, [
%=======================================================================

	  q(0,20,line), generic_horizontal_details( [ [ `Phone`, `No`, `.` ], 200, buyer_ddi, s1 ] )

] ).

%=======================================================================
i_rule( get_buyer_fax, [
%=======================================================================

	  q(0,20,line), generic_horizontal_details( [ [ `Fax`, `No`, `.` ], 200, buyer_fax, s1, newline ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  q0n(line), read_ahead( generic_horizontal_details( [ [ `Total`, or( [ [ `GBP`, `Excl`, `.`, `VAT` ], `EUR` ] ) ], 250, total_net, d, newline ] ) )
	  
	, check( total_net = Net )
	
	, total_invoice( Net )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	 line_header_line

	, q0n( [

		  or( [ 
		
			  line_invoice_line
			  
			, line_freight_line
			
			, line_continuation_line
			
			, line

		] )

	] )
	
	, q10( get_delivery_contact )
	
	, q10( get_delivery_ddi )

	, line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Phase`, `Job`, `No`, `.` ] ).
%=======================================================================
i_line_rule_cut( line_continuation_line, [ append( line_descr(s1), ` `, `` ), newline ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ or( [ [ `Total`, or( [ [ `GBP`, `Excl` ], `EUR` ] ) ], [ `Page` ], [ `Effective`, newline ] ] ) ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  q10( generic_item( [ phase, d, tab ] ) )
	  
	, generic_item_cut( [ job, d, q10( tab ) ] )
	
	, generic_item( [ line_item, [ begin, q(dec,5,10), end ], tab ] )
	
	, generic_item( [ line_descr, s1, tab ] )
	
	, generic_item_cut( [ line_quantity, d, q10( tab ) ] )
	
	, generic_item( [ line_quantity_uom_code, s1, tab ] )
	
	, generic_item_cut( [ line_unit_amount, d, q10( tab ) ] )
	
	, q10( generic_item( [ line_percent_discount, d, tab ] ) )

	, generic_item( [ line_net_amount, d, newline ] )
	
	, with( invoice, due_date, Due )
	
	, line_original_order_date( Due )
	
	, count_rule

] ).

%=======================================================================
i_line_rule_cut( line_freight_line, [
%=======================================================================

	  generic_item( [ phase, d, tab ] )
	  
	,  generic_item( [ job, d, tab ] )
	
	, line_item( `Missing` )
	
	, generic_item( [ line_descr, s, tab ] )
	
	, generic_item( [ line_quantity, d, tab ] )

	, generic_item( [ line_unit_amount, d, tab ] )

	, generic_item( [ line_net_amount, d, newline ] )
	
	, count_rule

] ).

%=======================================================================
i_line_rule_cut( get_delivery_contact, [
%=======================================================================

	  qn0(
		or( [ `FAO`
			, `ATT` 
			, `*`
			, `Site`
			, `Contact`
		] ) 
	)
	  
	, generic_item( [ delivery_contact, s1, newline ] )

] ).

%=======================================================================
i_line_rule_cut( get_delivery_ddi, [
%=======================================================================

	  qn0( 
		or( [ `MOB`
			, `TEL`
			, `:`
		] )
	)

	, generic_item( [ delivery_ddi, sf, [ q10( `*` ), newline ] ] )

] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 1, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).

