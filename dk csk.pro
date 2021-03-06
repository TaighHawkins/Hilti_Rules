%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - DK CSK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( dk_csk, `24 September 2014` ).

i_date_format( _ ).
i_format_postcode( X, X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number
	
	, get_order_date

	, get_delivery_address
	
	, get_buyer_contact
	
	, get_buyer_ddi
	
	, get_buyer_email
	
	, get_delivery_contact
	
	, get_delivery_ddi
	
	, get_delivery_fax
	
	, get_delivery_email
	
	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

	, get_totals
	
] ).

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

	, buyer_registration_number( `DK-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`2700`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `10550149` ) ]    %TEST
	    , suppliers_code_for_buyer( `11274120` )                      %PROD
	]) ]

	, set( reverse_punctuation_in_numbers )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================	  
	  
	  q(0,10,line), generic_horizontal_details( [ [ `Rekvisition`, `/`, `projekt`, qn0( `.` ), `:` ], order_number, s1 ] )
	
] ).

%=======================================================================
i_rule( get_order_date, [
%=======================================================================

	  q(0,10,line), generic_horizontal_details( [ [ `Dato`, qn0( `.` ), `:` ], invoice_date_x, s1 ] )
	  
	, check( string_string_replace( invoice_date_x, `-`, `/`, Date ) )
	
	, invoice_date( Date )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [ 
%=======================================================================

	  q(0,10,line), generic_vertical_details( [ [ `Leveringsadresse` ], delivery_party, s1, newline ] )
	  
	, generic_horizontal_details( [ nearest( delivery_party(start), 10, 10 ), delivery_street, s1 ] )
	
	, generic_line( [ 
	
		[ nearest( delivery_party(start), 10, 10 )
		
			, generic_item( [ delivery_postcode, [ begin, q(dec,4,4), end ] ] )
			
			, generic_item( [ delivery_city, s1 ] )
			
		]
		
	] )
	
	, q10( [ generic_horizontal_details( [ nearest( delivery_party(start), 10, 10 ), customer_comments, s1 ] )
	
		, check( customer_comments = Com )
		
		, shipping_instructions( Com )
		
	] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACT DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	  q(0,5,line), generic_vertical_details( [ [ `Indkøber` ], buyer_contact, s1, newline ] )

] ).

%=======================================================================
i_rule( get_buyer_ddi, [ 
%=======================================================================

	  q(0,5,line), generic_horizontal_details( [ [ `Direkte`, `tlf`, qn0( `.` ), `:` ], buyer_ddi, s1, newline ] )

] ).

%=======================================================================
i_rule( get_buyer_email, [ 
%=======================================================================

	  q(0,5,line), generic_horizontal_details( [ [ `Email`, qn0( `.` ), `:` ], buyer_email, s1, newline ] )

] ).

%=======================================================================
i_rule( get_delivery_contact, [ 
%=======================================================================

	  q(0,25,line), generic_horizontal_details( [ [ at_start, `Att`, qn0( `.` ), `:` ],delivery_contact, s1 ] )

] ).

%=======================================================================
i_rule( get_delivery_ddi, [ 
%=======================================================================

	  q(0,25,line), generic_horizontal_details( [ [ at_start, `tlf`, q0n(word), `)` ], delivery_ddi, s1 ] )

] ).

%=======================================================================
i_rule( get_delivery_fax, [ 
%=======================================================================

	  q(0,25,line), generic_horizontal_details( [ [ at_start, `Fax`, qn0(word), `:` ], delivery_fax, s1 ] )

] ).

%=======================================================================
i_rule( get_delivery_email, [ 
%=======================================================================

	  q(0,25,line), generic_horizontal_details( [ [ at_start, `Email`, qn0( `.` ), `:` ], delivery_email, s1 ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [ qn0(line), get_totals_line ] ).
%=======================================================================
i_line_rule( get_totals_line, [ 
%=======================================================================

	  q0n(anything), `Samlet`, `rekvisition`, dummy(s1), tab
	  
	, read_ahead( [ generic_item( [ total_net, d, newline] ) ] )
	
	, generic_item( [ total_invoice, d, newline ] )
	  
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line
	 
	, trace( [ `found header` ] )

	, q0n( [

		  or( [ 
		
			  line_invoice_rule
			  
			, line_continuation_line

			, line

		] )

	] )
		
	, line_end_line

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `Varenummer`, `Betegnelse` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `Samlet`, `rekvisition` ] ).
%=======================================================================
i_line_rule_cut( line_continuation_line, [ peek_fails( or( [ `Ordren`, `Ordrebekræftelse` ] ) ), append( line_descr(s1), ` `, `` ), newline ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	  
	, generic_line( [ generic_item( [ line_item, [ begin, q(dec,4,10), end ] ] ) ] )
	
	, count_rule
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ line_item_for_buyer, w, q10( tab ) ] )

	, generic_item( [ line_descr, s1, tab ] )

	, generic_item_cut( [ line_quantity, d ] )

	, generic_item( [ line_quantity_uom_code, s1, tab ] )

	, generic_item( [ line_unit_amount, d, tab ] )

	, generic_item( [ line_net_amount, d, newline ] )

] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).

%=======================================================================
i_user_check( danish_month, Date_In, Date_Out ):-
%=======================================================================

	string_to_lower( Date_In, Date_L ),
	sys_string_split( Date_L, `-`, [ Day, Month, Year ] )
	, date_lookup( Month, Number )
	, sys_stringlist_concat( [ Day, Number, Year ], `/`, Date_Out )
.

date_lookup( `januar`, `01` ).
date_lookup( `jan`, `01` ).
date_lookup( `februar`, `02` ).
date_lookup( `feb`, `02` ).
date_lookup( `marts`, `03` ).
date_lookup( `mar`, `03` ).
date_lookup( `april`, `04` ).
date_lookup( `apr`, `04` ).
date_lookup( `kan`, `05` ).
date_lookup( `juni`, `06` ).
date_lookup( `jun`, `06` ).
date_lookup( `juli`, `07` ).
date_lookup( `jul`, `07` ).
date_lookup( `august`, `08` ).
date_lookup( `aug`, `08` ).
date_lookup( `september`, `09` ).
date_lookup( `sep`, `09` ).
date_lookup( `oktober`, `10` ).
date_lookup( `okt`, `10` ).
date_lookup( `november`, `11` ).
date_lookup( `nov`, `11` ).
date_lookup( `december`, `12` ).
date_lookup( `dec`, `12` ).
