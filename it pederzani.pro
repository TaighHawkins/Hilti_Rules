%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - IT PEDERZANI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( it_pederzani, `10 June 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number

	, get_delivery_details
	
	, get_contacts
	
	, get_customer_comments
	
	, get_shipping_instructions

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
	  [ test(test_flag), suppliers_code_for_buyer( `13033688` ) ]    %TEST
	    , suppliers_code_for_buyer( `13033688` )                      %PROD
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
	  
	q(0,20,line)

	, generic_vertical_details( [ [ `Numero` ], `Numero`, q(0,0), (end,5,30),  order_number, sf, [ q10( tab ), invoice_date(date) ] ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACT DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_contacts, [ 
%=======================================================================

	  q(0,5,line), generic_horizontal_details( [ [ `Da`, `:`, tab, `A`, `:` ] ] )
	  
	, generic_horizontal_details( [ nearest_word( generic_hook(start), 0, 10 ), buyer_contact, s1 ] )

	, check( buyer_contact = Con )
	, delivery_contact( Con )

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

	, q(5,0, gen_line_nothing_here( [ delivery_hook(start), 10, 10 ] ) )
	, or( [ [ generic_line( [ [ nearest( delivery_hook(start), 10, 10 ), `Nostro`, `magazzino` ] ] )
			, delivery_note_reference( `ITPEDEMAGAZZINO` )
			, set( delivery_note_ref_no_failure )
		]
		
		, [ delivery_thing( [ delivery_dept ] )
	
			, q(5,0, gen_line_nothing_here( [ delivery_hook(start), 10, 10 ] ) )
			, delivery_thing( [ delivery_street ] )
			
			, q(5,0, gen_line_nothing_here( [ delivery_hook(start), 10, 10 ] ) )
			, delivery_postcode_city_state_line
			
			, or( [ [ test( need_state ), q(5,0, gen_line_nothing_here( [ delivery_hook(start), 10, 25 ] ) )
					, generic_horizontal_details( [ [ nearest( delivery_hook(start), 10, 25 ), `(` ], delivery_state, sf, `)` ] )
				]
				, peek_fails( test( need_state ) )
			] )
	
			, trace( [ `delivery stuffs`, delivery_city, delivery_state, delivery_postcode ] )
			
			, delivery_party( `PEDERZANI IMPIANTI SRL` )
			
		]

	] )
	
] ).

%=======================================================================
i_line_rule( delivery_header_line, [ q0n(anything), read_ahead( `Destinazione` ), delivery_hook(w), `merce` ] ).
%=======================================================================
i_line_rule( delivery_thing( [ Variable ] ), [
%=======================================================================

	  nearest( delivery_hook(start), 10, 10 )
	  
	, Read_Variable
	
	, newline
	
	, trace( [ String, Variable ] )

] ):-

	  Read_Variable =.. [ Variable, s1 ]
	, sys_string_atom( String, Variable )
.

%=======================================================================
i_line_rule( delivery_postcode_city_state_line, [
%=======================================================================

	  nearest( delivery_hook(start), 10, 10 )
	  
	, delivery_postcode( f( [ begin, q(dec,5,5), end ] ) )
	
	, delivery_city(sf)
	
	, or( [ [ `(`
	
			, delivery_state( f( [ begin, q(alpha,2,2), end ] ) ), `)`
		]
		
		, [ newline, set( need_state ) ]
	] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_customer_comments, [ 
%=======================================================================

	customer_comments( `` ), q0n(line)
	
	, generic_line( [ `Note` ] )
	
	, q0n( generic_line( [ [ append( customer_comments(s1), ``, ` ` ), newline ] ] ) )
	
	, line_header_line
	
] ).

%=======================================================================
i_rule( get_shipping_instructions, [ 
%=======================================================================

	shipping_instructions( `` ), q0n(line)
	
	, generic_line( 1, 180, 500, [ `Trasporto` ] )
	
	, q0n( generic_line( 1, 180, 500, [ [ append( shipping_instructions(s1), ``, ` ` ), newline ] ] ) )
	
	, generic_line( [ [ q0n(anything), `Indicare`, `Sempre` ] ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [ q0n(line), totals_line ] ).
%=======================================================================
i_line_rule( totals_line, [
%=======================================================================

	 q0n(anything), `Totale`, `lordo`, `a`, `corpo`, `:`, tab
	 
	, q10( `€` ), set( regexp_cross_word_boundaries )
	
	, read_ahead( [ total_net(d) ] )
	
	, total_invoice(d)
	
	, clear( regexp_cross_word_boundaries )
	
	, trace( [ `total invoice`, total_invoice ] )

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
		
			  line_invoice_line

			, line

		] )

	] )

	, line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Cod`, `.`, `art`, `.`, tab, `Marca`, tab, `Cod`, `.`, `Produt`, `.` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	  or( [ [ `Totale`, `lordo` ]
	
		, `SEGUE`
	
	] )

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item_cut( [ line_item_for_buyer, s1, tab ] )
	  
	, generic_item_cut( [ marca, s1, tab ] )

	, generic_item_cut( [ line_item, [ begin, q(dec,4,14), end ], tab ] )
	
	, generic_item_cut( [ line_descr, s1, tab ] )
	
	, q01( [ append( line_descr(s1), ` `, `` ), tab ] )
	
	, generic_item_cut( [ line_quantity_uom_code, w, q10( tab ) ] )

	, generic_item_cut( [ line_quantity, d, tab ] )

	, generic_item_cut( [ line_unit_amount, d, tab ] )
	
	, generic_item_cut( [ line_net_amount, d ] )
	
	, q0n(anything), `€`, num(d), q10( tab )

	, generic_item_cut( [ line_original_order_date, date, newline ] )
	
] ).
