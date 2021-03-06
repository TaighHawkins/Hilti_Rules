%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - INDUSTRIAL ACOUSTICS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( industrial_acoustics, `11 January 2015` ).

i_pdf_parameter( same_line, 9 ).
i_pdf_parameter( new_line, 10 ).

i_date_format( _ ).

i_correlate_amounts_total_to_use( total_net, net_subtotal_1).
i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).
i_user_field( invoice, delivery_district, `Delivery District` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number

	, get_invoice_date

	, get_buyer_email
	
	, get_buyer_contact

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

	, buyer_registration_number( `GB-IAC` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`4400`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, suppliers_code_for_buyer( `12329997` )
	
	, delivery_note_number( `12329997` )
	
	, sender_name( `Industrial Acoustics Company Ltd.` )

	, buyer_ddi( `01962 873 000` )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  q(0,10,line), generic_horizontal_details( [ [ `Purchase`, `Order` ], order_number, s1 ] ) 
	  
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE DATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_date, [ 
%=======================================================================

	  q(0,15,line), generic_horizontal_details( [ [ `Date`, `:` ], invoice_date, date ] ) 
	  
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_email, [ buyer_email( From ) ] ):- 
%=======================================================================
	i_mail( from, From ),
	not( q_sys_sub_string( From, _, _, `@hilti.com` ) )
.

%=======================================================================
i_rule( get_buyer_contact, [ q0n(line), generic_horizontal_details( [ [ `Ordered`, `By`, `:` ], buyer_contact, s1 ] ) ] ).
%=======================================================================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  q0n(line), generic_horizontal_details( [ [ `Total` ], total_net, d ] )
	  
	, check( total_net = Net )
	
	, total_invoice( Net )
	
	, or( [ [ with( invoice, delivery_charge, Charge )
	
			, check( sys_calculate_str_subtract( total_net, Charge, Net_1 ) )
			
			, net_subtotal_2( Charge )
			
			, gross_subtotal_2( Charge )
			
		]
		
		, [ without( delivery_charge )
		
			, check( total_net = Net_1 )
			
		]
		
	] )
	
	, net_subtotal_1( Net_1 )
	
	, gross_subtotal_1( Net_1 )

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
		
			  line_invoice_rule
	
			, line

		] )

	] )
		
	, line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `No`, `.`, newline ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ q0n(word), `Special` ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	  
	, or( [ generic_line( [ [ generic_item( [ line_item, [ begin, q(dec,4,10), end ] ] ), line_descr(s1) ] ] )
	
		, [ gen1_parse_text_rule( [ -300, 200, or( [ line_check_line, line_end_line ] )
											, thing, [ begin, q(any,1,10), end ] ] )

			, check( captured_text = Descr )

			, or( [ [ check( i_user_check( check_for_item_code, Descr, Item, New_Descr ) )
			
					, line_item( Item ), line_descr( New_Descr ) 
					
				]
			
				, [ line_item( `Missing` ), line_descr( Descr ) ]
				
			] )
			
		]
		
	] )
	
	, trace( [ `Description`, line_descr ] )
	
	, trace( [ `Line item`, line_item ] )

	, q10( [ check( i_user_check( check_for_delivery, line_descr ) )

		, line_type( `ignore` )
		
		, check( line_net_amount = Net )

		, delivery_charge( Net )
			
	] )
	
	, line_quantity_uom_code( `EA` )

] ).

%=======================================================================
i_line_rule_cut( line_check_line, [ q0n(anything), some(date) ] ).
%=======================================================================
i_line_rule_cut( line_descr_line, [ generic_item( [ line_descr, s1, newline ] ) ] ).
%=======================================================================
i_line_rule_cut( line_continuation_line, [ append( line_descr(s1), ` `, `` ), newline ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item_cut( [ line_order_line_number, d, tab ] )

	, generic_item_cut( [ line_quantity, d, tab ] )
	
	, q10( generic_item( [ dummy_uom, s1, tab ] ) )

	, generic_item_cut( [ dummy_item, s1, tab ] )
	
	, generic_item_cut( [ line_original_order_date, date, tab ] )

	, generic_item_cut( [ line_net_amount, d, newline ] )
	
] ).

%=======================================================================
i_user_check( check_for_delivery, Delivery ):-
%=======================================================================

	  string_to_lower( Delivery, Delivery_L )
	, sys_string_split( Delivery_L, ` `, Delivery_Words )
	, q_sys_member( Delivery_Word, Delivery_Words )
	, q_sys_member( Delivery_Word, [ `delivery`, `deliver`, `freight`, `carriage`, `haulage` ] )
	, trace( `delivery line, line being ignored` )
.

%=======================================================================
i_user_check( check_for_item_code, Descr, Item, New_Descr ):-
%=======================================================================

	  string_string_replace( Descr, `#`, ` # `, Descr_Rep )
	, string_to_lower( Descr_Rep, Descr_L )
	, sys_string_split( Descr_Rep, ` `, Descr_List_Normal )
	, sys_string_split( Descr_L, ` `, Descr_List )
	
	
	, ( sys_append( _, [ `pt`, `no`, Item | _ ], Descr_List )
		, Descr = New_Descr
		
		;	sys_append( _, [ `#`, Item | _ ], Descr_List )
			, Descr = New_Descr
		
		;	
		
		 ( sys_append( _, [ `supplier`, `item`, `number`, Item | _ ], Descr_List )
			;	sys_append( _, [ `item`, `no`, Item | _ ], Descr_List )
		)
		, q_sys_member( Descr_End, [ `Supplier`, `ITEM` ] )
		, sys_append( New_Descr_List, [ Descr_End | _ ], Descr_List_Normal )
		, sys_stringlist_concat( New_Descr_List, ` `, New_Descr )
	)
.