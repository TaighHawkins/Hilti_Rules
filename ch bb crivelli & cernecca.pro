%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - CH BB CRIVELLI & CERNECCA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( ch_bb_crivelli_cernecca, `9 March 2015` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_date_format( _ ).
i_format_postcode( X, X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	  
	, get_order_number
	, gen_capture( [ [ `Data`, tab, `:` ], invoice_date, date, newline ] )
	
	, get_delivery_date
	
	, get_delivery_note_reference

	, gen_capture( [ [ `Responsabile`, tab, `:` ], delivery_contact, s1, newline ] )
	, gen_capture( [ [ at_start, `e`, `-`, `mail`, peek_fails(`info`) ], delivery_email, s1, newline ] )
	
	, gen_capture( [ [ `Responsabile`, tab, `:` ], buyer_contact, s1, newline ] )
	, gen_capture( [ [ at_start, `e`, `-`, `mail`, peek_fails(`info`) ], buyer_email, s1, newline ] )

	, check( i_user_check( gen_cntr_set, 20, 0 ) )
	
	, get_totals

	, get_invoice_lines
	
	, [ without( line_net_amount ), force_result( `defect` ) ]

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
	
	, buyer_registration_number( `CH-ADAPTRI` )

	, or( [
		[ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	] )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`2100`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, or( [ [ test( test_flag ), suppliers_code_for_buyer( `10537375` ) ]
		, suppliers_code_for_buyer( `10537375` )
	] )
	
	, set( reverse_punctuation_in_numbers )
	
	, sender_name( `BB Crivelli & Cernecca S.A.` )
	, set( delivery_note_ref_no_failure )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================	  
	  
	  q0n(line)
	
	, generic_horizontal_details( [ [ `Oggetto`, tab, `:` ], order_number, s1, newline ] )
	
	, order_number_append
	
] ).

%=======================================================================
i_line_rule( order_number_append, [
%=======================================================================	  
	  
	  `Impianto`, tab, `:`
	
	, append( order_number(s1), `/`, `` )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_date, [
%=======================================================================

	  with( invoice, invoice_date, Date )
	
	, check( i_user_check( add_1_to_date, Date, Delivery_Date ) )
	
	, delivery_date( Delivery_Date ), trace( [ `delivery_date`, delivery_date ] )

] ).

%-----------------------------------------------------------------------
i_user_check( add_1_to_date, Date_in, Date_out )
%-----------------------------------------------------------------------
:-
	date_string( Date_Array, _, Date_in ),
	date_add( Date_Array, days(1), New_Date_Array ),
	date_string( New_Date_Array, `d.m.y`, Date_out )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY NOTE REFERENCE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_note_reference, [
%=======================================================================

	  q(0,25,line)
	  
	, generic_horizontal_details( [ [ `Luogo`, `consegna`, tab, `:` ], delivery_note_reference_x, w, or( [ `,`, gen_eof ] ) ] )
	
	, check( i_user_check( prepend_reference, delivery_note_reference_x, Ref ) )
	
	, delivery_note_reference( Ref )
	
	, trace( [ `delivery_note_reference`, delivery_note_reference ] )
	
] ).

%-----------------------------------------------------------------------
i_user_check( prepend_reference, Ref_in, Ref_out )
%-----------------------------------------------------------------------
:-
	string_to_upper( Ref_in, REF_IN ),
	strcat_list( [ `CHCRIV`, REF_IN ], Ref_out )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACT DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [
%=======================================================================

	  q(0,25,line)
	  
	, xml_tag_line( [ `Kunde` ] )
	
	, q(0,2,line), xml_tag_line( [ `Name`, buyer_contact ] )
	, check( buyer_contact = Con )
	, delivery_contact( Con )
	
	, xml_tag_line( [ `Email`, buyer_email ] )
	, check( buyer_email = Email )
	, delivery_email( Email )

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
	  
	, check( total_net = Net )
	, total_invoice( Net )
	
	, trace( [ `got totals` ] )

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
	  
	, qn0( [ peek_fails( line_end_line )
	
		, or( [
		
			line_invoice_line
			
			, [ line, force_result( `defect` ), trace( [ `missed line` ] ) ]
			
		] )
		
	] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [
%=======================================================================

	  `Art`, `.`, `No`, `.`, q10( [ `/`, `Tipo` ] ), tab, `Descrizione`, tab, `Dimensione`

] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	  `SCONTO`, `OGGETTO`, `SUPPLEMENTARE`

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ line_item, s1, tab ] )
	
	, generic_item( [ line_descr, s1, tab ] )
	
	, q10( generic_item( [ dimensione, s1, tab ] ) )
	
	, generic_item( [ line_quantity_uom_code, w ] )
	, generic_no( [ line_quantity, d, newline ] )
	
	, line_net_amount(`0`)
	
	, count_rule

] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )	
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).