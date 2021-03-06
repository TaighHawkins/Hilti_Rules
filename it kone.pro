%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - IT KONE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( it_kone, `23 January 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number
	
	, get_order_date

	, get_delivery_details

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

	, buyer_registration_number( `IT-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`7500`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `10658906` ) ]    %TEST
	    , suppliers_code_for_buyer( `13133276` )                      %PROD
	]) ]

%	, [ or([ 
%	  [ test(test_flag), delivery_note_number( `10658906` ) ]    %TEST
%	    , delivery_note_number( `13133276` )                      %PROD
%	]) ]

	, set( reverse_punctuation_in_numbers )
	
	, buyer_contact( `MARIELLA VECCHIETTI` )
	
	, buyer_email( `mariella.vecchietti@kone.com` )
	
	, delivery_contact( `MARIELLA VECCHIETTI` )
	
	, delivery_email( `mariella.vecchietti@kone.com` )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================	  
	  
	  q(0,10,line)
	  
	, or( [ generic_vertical_details( [ [ `Numero`, `Ordine` ], `Numero`, start, order_number, s1 ] )
	
		, generic_vertical_details( [ [ `Buyer`, `'`, `s`, `order` ], `Buyer`, start, order_number, s1 ] )
		
	] )
	  
] ).

%=======================================================================
i_rule( get_order_date, [
%=======================================================================

	  q(0,5,line)
	  
	, or( [ or( [ generic_vertical_details( [ [ `Data`, tab, `Data` ], `Data`, start, invoice_date, date, tab ] )
	
			, generic_vertical_details( [ [ `Date`, tab, `Date` ], `Date`, start, invoice_date, date, tab ] )
			
		] )
	
		, [ or( [ generic_vertical_details( [ [ `Data`, tab, `Data` ], `Data`, start, all_the_dates, s1, newline  ] )
		
				, generic_vertical_details( [ [ `Date`, tab, `Date` ], `Date`, start, all_the_dates, s1, newline  ] )
			
			] )
		
			, check( i_user_check( split_the_date, all_the_dates, Date ) )
			
			, invoice_date( Date )
			
		]
		
	] )
	  
] ).

%=======================================================================
i_user_check( split_the_date, String_In, Date )
%-----------------------------------------------------------------------
:- sys_string_split( String_In, ` `, [ Date | _ ] ).
%=======================================================================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [ 
%=======================================================================

	  q(0,25,line), delivery_header_line
	  
	, check( hook(start) = Start )
	
	, check( sys_calculate( Left, Start - 10 ) )
	  
	, delivery_thing( 1, Left, -10, [ delivery_party ] )
	
	, q10( delivery_thing( 1, Left, -10, [ delivery_dept ] ) )
	
	, delivery_thing( 1, Left, -10, [ delivery_street ] )
	
	, delivery_city_and_postcode_line( 1, Left, -10 )

] ).


%=======================================================================
i_line_rule( delivery_header_line, [ read_ahead( [ or( [ [ `Destinazione`, `merce` ], [ `Delivery`, `Address` ] ] ) ] ), hook(w)] ).
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

	  q10( [ `I`, `-` ] )
	  
	, q10( generic_item( [ delivery_postcode, [ q(any,0,20), begin, q(dec,5,5), end ] ] ) )

	, or( [ [ generic_item( [ delivery_city, s, q10( tab ) ] )
	
			, q01( [ `(`, word, `)`, q10( tab ) ] )
	
			, generic_item( [ delivery_state, [ begin, q(alpha,2,2), end ] ] )
			
		]
		
		, [ generic_item( [ delivery_city, sf, q10( tab ) ] )
		
			, `(`, generic_item( [ delivery_state, [ begin, q(alpha,2,2), end ], `)` ] )
			
		]
		
		, generic_item( [ delivery_city, s1 ] )
		
	] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [ 
%=======================================================================

	  q(0,200,line)
	  
	, or( [ generic_vertical_details( [ [ `Prezzo`, `Totale`, `Ordine` ], `Ordine`, start, 10, 50, total_net, d, gen_eof ] )
	
		, generic_vertical_details( [ [ `Price`, tab, `Total` ], `Total`, start, 75, 0, total_net, d, gen_eof ] )
		
	] )
	  
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
	 
	, trace( [ `found header` ] )

	, q0n( [

		  or( [ 
		
			  [ line_invoice_line, line_description_line ]

			, line

		] )

	] )
		
	, line_end_line

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `Pos`, `.`, q01(tab), or( [ `Descrizione`, `References` ] ) ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ qn0(anything), or( [ `Totale`, `Total` ] ) ] ).
%=======================================================================
i_line_rule_cut( line_description_line, [ generic_item( [ line_descr, s1, gen_eof ] ) ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ line_order_line_number, d, `q01`, tab ] )
		  
	, generic_item( [ line_item_for_buyer, s1, tab ] )

	, generic_item( [ line_original_order_date, date, tab ] )

	, generic_item( [ line_quantity, d, `q10`, tab ] )
	
	, generic_item( [ line_quantity_uom_code, s1, tab ] )

	, generic_item( [ line_unit_amount, d, none ] ), `/`, tab

	, generic_item( [ line_net_amount, d, newline ] )

] ).
