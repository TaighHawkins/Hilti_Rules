%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - FR RESO LOGISTIQUE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( fr_reso_logistique, `20 April 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_date
	
	, get_order_number
	
	, get_delivery_address

%	, get_contacts % Removed in favour of fixed values

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

	, buyer_registration_number( `FR-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`0900`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, or( [ [ test( test_flag ), suppliers_code_for_buyer( `10558391` ) ]	
				, suppliers_code_for_buyer( `20896184` )		
	] )
	
	, or( [ [ test( test_flag ), delivery_note_number( `10558391` ) ]	
				, delivery_note_number( `20896184` )		
	] )
	
	, set( reverse_punctuation_in_numbers )

	, sender_name( `RESO LOGISTIQUE` )
	
	, buyer_dept( `FRRESOCONTACT` )
	, delivery_from_contact( `FRRESOCONTACT` )
	
	, type_of_supply( `01` )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  q(0,2,line), generic_horizontal_details( [ [ `CDE`, `:` ], order_x, s1 ] )
	  
	, q(0,25,line), generic_horizontal_details( [ [ `Affaire`, `:` ], order_y, s1 ] )
	
	, check( order_x = X )
	
	, check( order_y = Y )
	
	, check( strcat_list( [ X, ` `, Y ], Order ) )
	
	, order_number( Order )

] ).


%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	  q(0,3,line), generic_horizontal_details( [ [ `Le`, `:` ], invoice_date_x, s1 ] )
	  
	, check( invoice_date_x = Date_x )
	
	, check( sys_string_split( Date_x, `-`, [ Day, Month_Word, Year ] ) )
	
	, check( i_user_check( convert_the_month, Month_Word, Month ) )
	
	, check( sys_stringlist_concat( [ Day, Month, Year ], `/`, Date ) )
	
	, invoice_date( Date )

] ).

%=======================================================================
i_user_check( convert_the_month, Month, Num )
%----------------------------------------
:-
%=======================================================================

	  string_to_lower( Month, Month_L )  
	, month_lookup( Month_L, Num )
.

month_lookup( `janvier`, `01` ).
month_lookup( `jan`, `01` ).
month_lookup( `février`, `02` ).
month_lookup( `fév`, `02` ).
month_lookup( `fev`, `02` ).
month_lookup( `mars`, `03` ).
month_lookup( `mar`, `03` ).
month_lookup( `avril`, `04` ).
month_lookup( `avr`, `04` ).
month_lookup( `mai`, `05` ).
month_lookup( `juin`, `06` ).
month_lookup( `jun`, `06` ).
month_lookup( `juillet`, `07` ).
month_lookup( `jul`, `07` ).
month_lookup( `août`, `08` ).
month_lookup( `aoû`, `08` ).
month_lookup( `aou`, `08` ).
month_lookup( `septembre`, `09` ).
month_lookup( `sep`, `09` ).
month_lookup( `octobre`, `10` ).
month_lookup( `oct`, `10` ).
month_lookup( `novembre`, `11` ).
month_lookup( `nov`, `11` ).
month_lookup( `décembre`, `12` ).
month_lookup( `déc`, `12` ).
month_lookup( `dec`, `12` ).

  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_contacts, [
%=======================================================================	  
	  
	  q(0,25,line), generic_horizontal_details( [ [ `Acheteur`, `:` ], contact_x, s1 ] )
	  
	, check( contact_x = Con_x )
	
	, check( strip_string2_from_string1( Con_x, `1234567890`, Con_Strip ) )
	
	, check( sys_string_split( Con_Strip, ` `, Con_Rev_List ) )
	
	, check( sys_reverse( Con_Rev_List, Con_List ) )
	
	, check( sys_stringlist_concat( Con_List, ` `, Con ) )
	
	, buyer_contact( Con )
	
	, delivery_contact( Con )
	
] ).
  
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================	  
	  
	  q(0,25,line), generic_horizontal_details( [ read_ahead( [ `sur`, `la`, `facture` ] ), delivery_hook, s1 ] )
	  
	, q01( line)
	
	, generic_line( [ [ nearest( delivery_hook(start), 10, 10 ), generic_item( [ delivery_party, s1 ] ) ] ] )
	
	, q(1,2,line)
	
	, delivery_postcode_and_city_line
	
] ).

%=======================================================================
i_line_rule( delivery_postcode_and_city_line, [
%=======================================================================	  
	  
	  nearest( delivery_hook(start), 10, 10 )
	  
	, generic_item( [ delivery_postcode, [ begin, q(dec,5,5), end ] ] )
	
	, generic_item( [ delivery_city, s1 ] )
	
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

	  q0n(anything)
	  
	, `en`, `EUR`,  tab

	, read_ahead( [ total_net(d) ] )

	, total_invoice(d), q10( word ), newline
	
	, trace( [ `total_invoice`, total_invoice ] )

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
i_line_rule_cut( line_header_line, [ `Ligne`, `Article` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `Montant`, `Global` ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [ 
%=======================================================================

	  line_invoice_line
	  
	, generic_line( [ generic_item( [ line_descr, s1, newline ] ) ] )
	
	, count_rule
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ trash, d, tab ] )
	  
	, qn0( or( [ `HLT`, `HIL`, `.` ] ) )
	
	, generic_item( [ line_item, [ begin, q(dec,4,10), end ], tab ] )

	, generic_item( [ line_original_order_date, date, tab ] )

	, generic_item( [ line_quantity, d, q10( tab ) ] )
	
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