%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - DK KONTECH
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( dk_kontech, `06 May 2014` ).

i_pdf_parameter( same_line, 6 ).

i_date_format( _ ).
i_format_postcode( X, X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number
	
	, get_order_date

	, get_delivery_details
	
	, get_buyer_contact
	
	, get_buyer_ddi
	
	, get_buyer_email

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
	    , suppliers_code_for_buyer( `11267918` )                      %PROD
	]) ]

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================	  
	  
	  q(0,10,line), generic_horizontal_details( [ [ `Ordre`, `:` ], order_number, s1, newline ] )
	
] ).

%=======================================================================
i_rule( get_order_date, [
%=======================================================================

	  q(0,15,line), generic_horizontal_details( [ [ `Vores`, `ordredato` ], invoice_date, date, newline ] )
	  
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACT DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	  q(0,20,line), generic_horizontal_details( [ [ `Vor`, `reference` ], buyer_contact, s1, tab ] )
	
	, check( buyer_contact = Con )
	
	, delivery_contact( Con )
	
] ).

%=======================================================================
i_rule( get_buyer_ddi, [ 
%=======================================================================

	  q(0,20,line), generic_horizontal_details( [ [ `Telefonnr`, `.` ], buyer_ddi_x, s1, tab ] )
	  
	, check( string_string_replace( buyer_ddi_x, `+45`, `0`, Ddi_x ) )
	
	, check( string_string_replace( Ddi_x, ` `, ``, Ddi ) )
	
	, buyer_ddi( Ddi )
	
	, delivery_ddi( Ddi )
	
] ).

%=======================================================================
i_rule( get_buyer_email, [ 
%=======================================================================

	  q(0,25,line), generic_horizontal_details( [ [ `E`, `-`, `mail` ], 150, buyer_email, s1, tab ] )
	
	, check( buyer_email = Email )
	
	, delivery_email( Email )
	
	, q10( customer_comments_line )
	
] ).

%=======================================================================
i_line_rule( customer_comments_line, [ 
%=======================================================================

	  or( [ [ without( customer_comments ), generic_item( [ customer_comments, s1, newline ] )
	  
			, check( customer_comments = Cust )
			
			, shipping_instructions( Cust )
			
		]
		
		, [ with( customer_comments ), read_ahead( append( customer_comments(s1), `~`, `` ) )
		
			, append( shipping_instructions(s1), `~`, `` ), newline
			
		]
		
	] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [ 
%=======================================================================

	  q(0,5,line), delivery_header_line
	  
	, check( hook(start) = Start )
	
	, check( sys_calculate( Left, Start - 10 ) )
	
	, or( [ [ q01( dummy_line ), delivery_thing( 1, Left, 500, [ delivery_party ] )
	
			, q01( dummy_line ), delivery_thing( 1, Left, 500, [ customer_comments ] )
			
			, check( customer_comments = Cust ), shipping_instructions( Cust )
			
		]
		
		, [ delivery_thing( 1, Left, 500, [ customer_comments ] )
			
			, check( customer_comments = Cust ), shipping_instructions( Cust )
			
			, delivery_party( `KONTECH DK V/NIELS OXENBØL JENSEN` )
			
		]
		
		, [ delivery_party( `KONTECH DK V/NIELS OXENBØL JENSEN` )
		
			, q(0,2, dummy_line )
		
		]
		
	] )
	
	, delivery_thing( 1, Left, 500, [ delivery_street ] )
	
	, delivery_city_and_postcode_line( 1, Left, 500 )

] ).


%=======================================================================
i_line_rule( dummy_line, [ dummy(s1), newline, check( dummy(end) < -200 ) ] ).
%=======================================================================
i_line_rule( delivery_header_line, [ q0n(anything), read_ahead( [ `Leveringsadresse` ] ), hook(w)] ).
%=======================================================================
i_line_rule( delivery_thing( [ Variable ] ), [
%=======================================================================

	  Read_Var
	  
	, trace( [ String, Variable ] )

] ):-

	Read_Var =.. [ Variable, s1 ]
	, sys_string_atom( String, Variable )
.

%=======================================================================
i_line_rule( delivery_city_and_postcode_line, [
%=======================================================================

	  delivery_postcode( f( [ begin, q(dec,4,4), end ] ) )
	  
	, delivery_city(s1)
	
	, trace( [ `delivery stuffs`, delivery_city, delivery_postcode ] )

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

	  `Totalbeløb`, q0n(anything), tab
	  
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

			, line

		] )

	] )
		
	, line_end_line

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `Deres`, `varenr`, `.`, `Deres` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `Totalbeløb` ] ).
%=======================================================================
i_line_rule_cut( line_continuation_line, [ append( line_descr(s1), ` `, `` ), newline ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
 
	, q10( line_continuation_line )
	
	, line_item_line
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ line_order_line_number, d, tab ] )
		  
	, generic_item( [ line_item_for_buyer, s1, tab ] )

	, generic_item( [ line_descr, s1, tab ] )
	
	, q01( [ append( line_descr(s1), ` `, `` ), tab ] )

	, generic_item( [ line_quantity, d, `q10`, tab ] )

	, generic_item( [ line_quantity_uom_code, s1, tab ] )

	, generic_item( [ line_unit_amount, d, tab ] )
	
	, q01( generic_item( [ line_percent_discount, d, tab ] ) )

	, generic_item( [ line_net_amount, d, tab ] )

	, generic_item( [ line_original_order_date, date, newline ] )
	
] ).

%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================

	  generic_item( [ dummy_no, d, tab ] )
	  
	, generic_item( [ line_item, s1, gen_eof ] )
	
] ).