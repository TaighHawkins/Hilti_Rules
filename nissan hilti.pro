%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - NISSAN HILTI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( nissan_hilti, `10 September 2014` ).

i_date_format( _ ).

i_user_field( line, zzf_contract_type, `ZZF contract type` ).

i_user_field( invoice, comparison_item, `Item of previous line for comparison` ).

i_correlate_amounts_total_to_use( total_net, net_subtotal_1).
i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_fleet_rule
	
	, get_order_number

	, get_invoice_date

	, get_delivery_contact

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

	, buyer_registration_number( `GB-NISSAN` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`4400`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, suppliers_code_for_buyer( `12266210` )
	
	, delivery_note_number( `12266211` )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FLEET RULE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fleet_rule, [ q0n(line), line_header_line, trace( [ `found header` ] ), q(5,0,up), get_fleet_line ] ).
%=======================================================================
i_line_rule( get_fleet_line, [
%=======================================================================

	  q0n(anything)
	  
	, `FLEET`

	, set( fleet_invoice )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ q( 0, 5, line ), generic_horizontal_details( [ [ `PURCHASE`, `ORDER`, `No` ], order_number, s1, tab ] ) ] ).
%=======================================================================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_date, [ q( 0, 5, line ), generic_horizontal_details( [ [ `Date` ], invoice_date, date, newline ] ) ] ).
%=======================================================================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_contact, [ q0n( line ), delivery_contact_line ] ).
%=======================================================================
i_line_rule( delivery_contact_line, [ 
%=======================================================================

	  `Recipient`, `:`, tab
	  
	, read_ahead( [ word, delivery_contact(sf), newline ] )
	
	, append( delivery_contact(w), ` `, `` )

	, trace( [ `delivery contact`, delivery_contact ] ) 

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [ q0n(line), buyer_contact_line ] ).
%=======================================================================
i_line_rule( buyer_contact_line, [ 
%=======================================================================

	  `Buyer`, `:`, tab
	  
	, read_ahead( [ word , buyer_contact(sf), or( [ tab, `Buyer` ] ) ] )
	
	, append( buyer_contact(w), ` `, `` )
	
	, trace( [ `buyer contact`, buyer_contact ] )

] ).

%=======================================================================
i_rule( get_buyer_email, [ q(0,10,line), generic_horizontal_details( [ [ `E`, `-`, `mail`, `:` ], buyer_email, s1, newline ] )] ).
%=======================================================================

%=======================================================================
i_rule( get_buyer_ddi, [ q(0,10,line), buyer_ddi_line ] ).
%=======================================================================
i_line_rule( buyer_ddi_line, [ 
%=======================================================================

	  `Tel`, `.`, `:`
	  
	, set( regexp_allow_partial_matching )
	
	, something_strange( f( [ q(dec("4"),2,2) ] ) )
	
	, wrap( buyer_ddi(s1), `0`, `` )
	
	, clear( regexp_allow_partial_matching )
	
	, trace( [ `buyer_ddi`, buyer_ddi ] )
	  
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  without( total_net )
	  
	, q0n(line), read_ahead( generic_horizontal_details( [ [ `ORDER`, `TOTAL`, `EXCLUDING`, `VAT`, q10( tab ), `GBP` ], 150, total_net, d, newline ] ) )
	  
	, generic_horizontal_details( [ [ `ORDER`, `TOTAL`, `EXCLUDING`, `VAT`, q10( tab ), `GBP` ], 150, total_invoice, d, newline ] )

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
			  
			, line_fleet_rule
			
			, line_item_line
			
			, line

		] )

	] )
		
	, line_end_line
			
] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `DESCRIPTION`, newline ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ or( [ [ `ORDER`, `TOTAL`, `EXCLUDING`, `VAT` ], [ `This`, `purchase`, `order`, `is` ] ] ) ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  peek_fails( test( fleet_invoice ) )
	  
	, line_invoice_line
	  
	, line_descr_line

] ).

%=======================================================================
i_line_rule_cut( line_item_line, [ 
%=======================================================================

	or( [ [ `item`, `no`, q10(`:`) ]
	
		, [ q0n(word), `Part`, `No`, q10( `:` ) ]
		
	] )
	
	, generic_item( [ line_item, [ begin, q(dec,4,10), end ], [ q10( `.` ), newline ] ] ) 
	
] ).

%=======================================================================
i_line_rule_cut( line_just_item_line, [ generic_item( [ line_item, [ begin, q(dec,4,10), end ], newline ] ) ] ).
%=======================================================================
i_line_rule_cut( line_descr_no_item_line, [  generic_item( [ line_descr, s1, newline ] ) ] ).
%=======================================================================
i_line_rule_cut( line_descr_line, [ q10(line_item(f([ begin, q(dec,4,10), end ] ) ) ), generic_item( [ line_descr, s1, newline ] ) ] ).
%=======================================================================
i_line_rule_cut( line_item_and_descr_line, [ generic_item( [ line_item, [ begin, q(dec,4,10), end ] ] ), generic_item( [ line_descr, s1, newline ] ) ] ).
%=======================================================================


%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ line_order_line_number, d, tab ] )
	  
	, generic_item( [ line_item_for_buyer, s1, tab ] )
	
	, generic_item( [ line_original_order_date, date, tab ] )
	
	, generic_item( [ line_quantity, d, tab ] )
	
	, generic_item( [ line_quantity_uom_code, s1, tab ] )
	
	, generic_item( [ line_unit_amount, d, tab ] )
	
	, generic_item( [ line_quantity_x, d, tab ] )
	
	, generic_item( [ line_quantity_uom_code_x, s1, tab ] )
	
	, generic_item( [ line_net_amount, d, newline ] )

] ).

%=======================================================================
i_rule_cut( line_fleet_rule, [
%=======================================================================

	  test( fleet_invoice )
	  
	, zzf_contract_type( `ZFPL` ) 
	
	, q10( [ without( type_of_supply ), type_of_supply( `S1` ) ] )
	
	, line_invoice_line
	
	, or( [ [ line_just_item_line
		
			, line_descr_no_item_line
		
		]
		
		, line_item_and_descr_line
		
	] )
	
	, total_calculation_rule
	
] ).

%=======================================================================
i_rule_cut( total_calculation_rule, [
%=======================================================================
	
	  check( line_item = Item )
	
	, check( line_net_amount = LNet )
	
	, or( [ [ without( comparison_item )
	
				, net_subtotal_1( LNet )
				
				, gross_subtotal_1( LNet )

			]
	
		, [ with( invoice, comparison_item, Comp )
		
			, or( [ [ check( q_sys_member( Item, [ Comp ] ) )
		
					, line_type( `net_subtotal_2` )
					
					, or( [ [ with( invoice, gross_subtotal_2, Gross_2 )
					
							, check( sys_calculate_str_add( LNet, Gross_2, New_Gross_2 ) )
						
							, remove( gross_subtotal_2 )
						
							, gross_subtotal_2( New_Gross_2 )
					
						]
						
						, [ without( gross_subtotal_2 ), gross_subtotal_2( LNet ), trace( [ `first gross 2`, gross_subtotal_2 ] ) ]
						
					] )
				
				]
				
				, [ check( not( q_sys_member( Item, [ Comp ] ) ) )
				
					, with( invoice, net_subtotal_1, Net_Sub_1 )
					
					, check( sys_calculate_str_add( Net_Sub_1, LNet, New_Sub_1 ) )
			
					, net_subtotal_1( New_Sub_1 )
					
					, gross_subtotal_1( New_Sub_1 )
			
				]
				
			] )
			
		]
		
	] )
	
	, remove( comparison_item )
	
	, comparison_item( Item )

] ).

i_op_param( xml_empty_tags( `ZZFMCONTRACTTYPE` ), _, _, _, _, Answer )
:-
	  line_lid_being_written( LID )
	  
	, result( _, LID, zzf_contract_type, Answer )
.


