%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - DE WOLF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( de_wolf, `12 May 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).

i_pdf_parameter( same_line, 8 ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [ get_fixed_variables, bitte_rule ] ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( bitte_rule, [ 
%=======================================================================

	  or( [ [ q0n(line), generic_horizontal_details( [ read_ahead( `Bitte` ), dummy, s1 ] )
	  
			, check( dummy(font) = 2 )
			
			, delivery_note_reference( `special_rule` )
			
		]
		
		, set( process_order )
		
	] )	

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_order_number
	
	, get_order_date

	, get_delivery_details

	, get_contacts
	
	, get_customer_comments

	, check( i_user_check( gen_cntr_set, 20, 0 ) )
	
	, get_totals

	, get_invoice_lines

] ):- grammar_set( process_order ).

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

	, buyer_registration_number( `DE-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`5000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, set( reverse_punctuation_in_numbers )
	
	, suppliers_code_for_buyer( `10239670` )
	
	, delivery_party( `Wolf System GmbH` )
	
	, sender_name( `Wolf System GmbH` )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================	  
	  
	  q(0,10,line), generic_horizontal_details( [ `BESTELLUNG`, order_number, s1 ] )
	
] ).

%=======================================================================
i_rule( get_order_date, [
%=======================================================================	  
	  
	  q(0,10,line), generic_horizontal_details( [ `Bestelldatum`, invoice_date, date ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACT DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_contacts, [ 
%=======================================================================

	  q(0,15,line)
	  
	, generic_horizontal_details( [ `Bearbeiter`, buyer_contact_x, s1 ] )
	
	, check( i_user_check( reverse_names, buyer_contact_x, Con ) )
	
	, buyer_contact( Con )
	
	, delivery_contact( Con )
	
	, delivery_ddi_line
	
	, generic_horizontal_details( [ nearest( buyer_contact_x(start), 10, 10 ), buyer_email, s1 ] )
	
	, check( buyer_email = Email )
	
	, delivery_email( Email )

] ).

%=======================================================================
i_user_check( reverse_names, Names_In, Names_Out ):- 
%=======================================================================
  
	  strip_string2_from_string1( Names_In, `,`, Names_In_Strip )  
	, sys_string_split( Names_In_Strip, ` `, Names_Rev ) 
	, sys_reverse( Names_Rev, Names )

	, wordcat( Names, Names_Out )
.

%=======================================================================
i_line_rule( delivery_ddi_line, [ 
%=======================================================================

	  nearest( buyer_contact_x(start), 10, 10 )
	  
	, ddi_pref(sf), `-`
	
	, check( ddi_pref = Pref_x )
	, check( string_string_replace( Pref_x, `+49`, `0`, Pref_y ) )
	, check( strip_string2_from_string1( Pref_y, `-/`, Pref ) )
	
	, ddi_suff(sf), q10( tab )
	
	, `Fax`, `:`, `-`
	
	, fax_suff(s1)
	
	, check( ddi_suff = DDI_S )
	, check( fax_suff = Fax_S )
	
	, check( strcat_list( [ Pref, DDI_S ], DDI ) )
	, check( strcat_list( [ Pref, Fax_S ], Fax ) )
	
	, buyer_ddi( DDI )
	, delivery_ddi( DDI )
	
	, buyer_fax( Fax )
	, delivery_fax( Fax )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( delivery_header_line, [ `Lieferort`, q10( tab ), q10( [ `Fa`, `.`, `Wolf`, `-` ] ), generic_item( [ delivery_dept, s1 ] ) ] ).
%=======================================================================
i_rule( get_delivery_details, [
%=======================================================================
	  
	  q(0,30,line), delivery_header_line
	  
	, q01( delivery_thing( [ delivery_address_line ] ) )

	, delivery_thing( [ delivery_street ] )
	
	, delivery_postcode_and_city_line
	
] ).


%=======================================================================
i_line_rule_cut( firma_line, [ `Firma`, newline ] ).
%=======================================================================
i_line_rule( delivery_thing( [ Variable ] ), [ nearest( delivery_dept(start), 10, 10 ), generic_item( [ Variable, s1 ] ) ] ).
%=======================================================================
i_line_rule( delivery_postcode_and_city_line, [
%=======================================================================

	  nearest( delivery_dept(start), 10, 10 )
	
	, q10( [ `D`, `-` ] ), generic_item( [ delivery_postcode, [ begin, q(dec,5,5), end ] ] )
	
	, generic_item( [ delivery_city, s1 ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_customer_comments, [
%=======================================================================
	  
	  q(0,30,line)
	  
	, generic_horizontal_details( [ `Kommission`, customer_comments, s1, newline ] )
	
	, check( customer_comments(start) = Start )
	
	, qn0( generic_line( [ [ nearest( Start, 10, 10 ), append( customer_comments(s1), `~`, `` ), newline ] ] ) )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  q0n(line), read_ahead( generic_horizontal_details( [ [ at_start, `Summe`, tab ], total_net, d, newline ] ) )
	  
	, check( total_net = Net )

	, total_invoice( Net )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line
	 
	, trace( [ `found header` ] )

	, qn0( [ peek_fails( line_end_line )

		  , or( [ 
		
			  line_invoice_rule
			  
			, line_continuation_line
			
			, line_defect_line

			, line

		] )

	] )

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `(`, `fremd`, `)` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `Summe` ] ).
%=======================================================================
i_line_rule_cut( line_defect_line, [ num(f([q(dec,1,2)])), q(2,2,[ tab, num(d) ] ), force_result( `defect` ), force_sub_result( `missed_line` ) ] ).
%=======================================================================
i_line_rule_cut( line_continuation_line, [ append( line_descr(s1), ` `, `` ), newline ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	
	, q10( line_buyer_item_line )
	
	, q10( [ check( line_item = `433372` ), delivery_note_reference( `special_rule` ) ] )

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  q01( [ dummy(s1), tab, check( dummy(end) < -400 ) ] )
	  
	, generic_item( [ line_order_line_number, d, q10( tab ) ] )
	
	, generic_item( [ line_item_for_buyer, [ begin, q(dec,4,10), end ], tab ] )
	
	, generic_item_cut( [ line_quantity, d ] )
	
	, generic_item( [ line_quantity_uom_code, w, q10( tab ) ] )
	
	, q10( [ generic_item_cut( [ line_other_qty, d ] )
	
		, generic_item( [ line_other_uom_code, w, q10( tab ) ] )
		
	] )

	, generic_item( [ line_descr, s1, q01( generic_item( [ hohe, d ] ) ) ] )

	, or( [ newline
	
		, [ tab, q10( generic_item_cut( [ lange, d, q10( tab ) ] ) )
	
			, generic_item( [ line_unit_amount, d, tab ] )
			
			, generic_item( [ line_net_amount, d, newline ] )
			
		]
		
	] )

] ).

%=======================================================================
i_line_rule_cut( line_buyer_item_line, [
%=======================================================================

	  q01( [ dummy(s1), tab, check( dummy(end) < -400 ) ] )
	  
	, `(`, generic_item( [ line_item, sf, [ q10( `)` ), tab ] ] )

	, append( line_descr(s1), ` `, `` ), newline

] ).