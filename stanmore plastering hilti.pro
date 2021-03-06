%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - STANMORE SCAFOLDING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( stanmore_scaffolding, `23 April 2015` ).

i_pdf_parameter( same_line, 6 ).

i_date_format( _ ).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_delivery_details
	
	, get_order_number

	, get_invoice_date
	
	, get_due_date

	, get_buyer_contact
	
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

	, buyer_registration_number( `GB-PLASTER` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`4400`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, suppliers_code_for_buyer( `12277972` )
	
	, delivery_party( `PLASTERING CONTRACTORS` )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  q(0,15,line), generic_horizontal_details( [ [ `Our`, `Order`, `Number`, `:` ], order_number, s1 ] ) 
	  
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE DATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_date, [ 
%=======================================================================

	  qn0(line), generic_horizontal_details( [ [ `Delivery`, `Date`, `:`, tab ], invoice_date, date, newline ] ) 
	  
] ).

%=======================================================================
i_rule( get_due_date, [ 
%=======================================================================

	  q( 0, 25, line ), generic_vertical_details( [ [ `Order`,`Required`, `By` ], `Order`, end, 30, 5, due_date, date, newline ] ) 
	  
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_email, [ buyer_email( From ) ] )
%-----------------------------------------------------------------------
:- i_mail( from, From ).
%=======================================================================
	
%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	q0n(line)
	
	, generic_line( [ `Print` ] )
	
	, generic_horizontal_details( [ [ at_start, `Name`, `:` ], buyer_contact, s1 ] )
  
] ).




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [
%=======================================================================

	  q0n(line), delivery_header_line
	  
	, or( [ [ q10(line), delivery_thing( [ delivery_street_two, s1 ] )
	
			, delivery_thing( [ delivery_street, s1 ] )
			
			, check( delivery_street_two = Two )
			
			, delivery_street( Two )

			, or( [ [ delivery_thing( [ delivery_city, s1 ] )

					, delivery_thing( [ delivery_postcode, pc ] )
					
				]
				
				, [ delivery_city_and_postcode_line ]
				
			] )
			
		]
		
		, [ q(0,5,line), generic_line( [ [ `Head`, `Office` ] ] )
		
			, delivery_note_number( `12277972` )
			
		]
		
	] )
	
] ).


%=======================================================================
i_line_rule( delivery_header_line, [ read_ahead( [ `Delivery`, `address` ] ) , hook(s1) ] ).
%=======================================================================
i_line_rule( delivery_thing( [ Variable, Parameter ] ), [
%=======================================================================

	  nearest( hook(start), 10, 10 )
	  
	, Read_Variable
	  
	, gen_eof
	
	, trace( [ String, Variable ] )
	
] ):-

	  Read_Variable =.. [ Variable, Parameter ]
	, sys_string_atom( String, Variable )
.

%=======================================================================
i_line_rule( delivery_city_and_postcode_line, [
%=======================================================================

	  nearest( hook(start), 10, 10 )
	  
	, generic_item( [ delivery_city, sf ] )
	
	, generic_item( [ delivery_postcode, pc ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  total_net( `0` )
	  
	, total_invoice( `0` )

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
i_line_rule_cut( line_header_line, [ `Qty`, tab, `Unit` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `Notes` ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line

	, or( [ check( line_item = Delivery )

		, check( i_user_check( check_for_delivery, Delivery ) )
		
		, line_type( `ignore` )

		, delivery_charge( Net )

	] )
	
	, line_net_amount( `0` )
	
	, count_rule
	
	, trace( [ `completed everything` ] )
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ line_quantity, d, tab ] )
	
	, generic_item( [ line_quantity_uom_code, s1, tab ] )
	
	, or( [ read_ahead( [ line_item_rule ] ), line_item( `Missing` ) ] )

	, generic_item( [ line_descr, s1, [ q01( [ tab, append( line_descr(s1), ` `, `` ) ] ), newline ] ] )
	
] ).

%=======================================================================
i_rule( line_item_rule, [ 
%=======================================================================

	  q0n(anything)
	  
	, generic_item( [ line_item, [ begin, q(dec,4,10), end ] ] )
	
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
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 1, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).