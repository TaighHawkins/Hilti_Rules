%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - DK SEAS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( dk_seas, `16 October 2014` ).

i_date_format( _ ).
i_format_postcode( X, X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number
	
	, get_order_date
	
	, get_due_date

	, get_delivery_details
	
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
	    , suppliers_code_for_buyer( `11283314` )                      %PROD
	]) ]
	
	, set( reverse_punctuation_in_numbers )
	, set( no_total_validation )
	, sender_name( `SEAS-NVE` )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================	  
	  
	  q(0,10,line), generic_horizontal_details( [ [ `Nr`, `.` ], order_number, s1 ] )
	
] ).

%=======================================================================
i_rule( get_order_date, [
%=======================================================================

	  q(0,10,line), generic_horizontal_details( [ `Oprettelsesdato`, invoice_date, date ] )
	
] ).

%=======================================================================
i_rule( get_due_date, [
%=======================================================================

	  q0n(line), generic_horizontal_details( [ [ `Leveringstid`, q0n(anything) ], due_date, date ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACT DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	  q0n(line), generic_horizontal_details( [ [ `Kontakt`, `:` ], buyer_contact, s1, newline ] )
	
	, check( buyer_contact = Con )
	
	, delivery_contact( Con )
	
] ).

%=======================================================================
i_rule( get_buyer_email, [ 
%=======================================================================

	  q0n(line), generic_horizontal_details( [ [ `E`, `-`, `mail`, `:` ], buyer_email, s1, newline ] )
	
	, check( buyer_email = Email )
	
	, delivery_email( Email )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( delivery_thing( [ Var ] ), [ nearest( generic_hook(start), 10, 10 ), generic_item( [ Var, s1 ] ) ] ).
%=======================================================================
i_rule( get_delivery_details, [ 
%=======================================================================

	  q0n(line), generic_horizontal_details( [ [ at_start, `Leveringsadresse` ] ] )
	
	, qn0( gen_line_nothing_here( [ generic_hook(start), 10, 10 ] ) )
	
	, delivery_thing( [ delivery_party ] )
	
	, delivery_thing( [ delivery_street ] )
	
	, delivery_postcode_city_line
	
] ).

%=======================================================================
i_line_rule( delivery_postcode_city_line, [ 
%=======================================================================

	  nearest( generic_hook(start), 10, 10 )
	  
	, q10( [ `DK`, `-` ] )
	
	, generic_item( [ delivery_postcode, [ begin, q(dec,4,5), end ] ] )
	
	, generic_item( [ delivery_city, s1 ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [ 
%=======================================================================

	  q0n(line)
	  
	, generic_horizontal_details( [ [ `Samlet`, `nettoværdi`, `uden`, `moms`, q10( tab ), word ], 350, total_net, d, newline ] )
	
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
		
			  line_invoice_rule
			  
			, line_item_for_buyer_line
			
			, line_discount_line
			
			, line_failure_line

			, line

		] )

	] )
		
	, line_end_line

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ read_ahead( `Pos` ), header(w), tab, `specifikation` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ 
%=======================================================================

	or( [ `Samlet` 

		, [ dummy(w), check( not( dummy(page) = header(page) ) ) ]
		
	] )
	
] ).

%=======================================================================
i_line_rule_cut( line_failure_line, [ num(f([q(dec,5,5)])), dum(s1), tab, force_result( `defect` ), force_sub_result( `missed_line` ) ] ).
%=======================================================================
i_line_rule_cut( line_continuation_line, [ append( line_descr(s1), ` `, `` ), newline ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	  
	, q01( line ), line_price_line
	
	, or( [ [ q(0,2,line), line_date_line ]
	
		, [ with( invoice, due_date, Due ), line_original_order_date( Due ) ]
		
	] )
	
	, q(0,2,line), line_item_line
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ line_order_line_number, d, q10( tab ) ] )

	, generic_item( [ line_descr, s1, tab ] )

	, generic_item_cut( [ line_quantity, d, q10( tab ) ] )

	, generic_item( [ line_quantity_uom_code, wf, [ q10( `.` ), tab ] ] )

	, generic_item( [ line_unit_amount_x, d, [ word, newline ] ] )

] ).

%=======================================================================
i_line_rule_cut( line_price_line, [ 
%=======================================================================

	or( [ `Positionsværdi`, `Positonsværdi` ] ), word, tab
	
	, generic_item( [ line_net_amount_x, d, newline ] )
	
	, check( sys_calculate_str_divide( line_net_amount_x, line_quantity, Unit ) )
	
	, line_unit_amount( Unit )
	
] ).

%=======================================================================
i_line_rule_cut( line_date_line, [ `LevTidspunkt`, q0n(word), generic_item( [ line_original_order_date, date, newline ] ) ] ).
%=======================================================================
i_line_rule_cut( line_item_line, [ 
%=======================================================================

	  `Deres`, `materialenr`, q10( `.` )
	  
	, generic_item( [ line_item, [ begin, q(dec,4,10), end ] ] )

] ).

%=======================================================================
i_line_rule_cut( line_item_for_buyer_line, [ 
%=======================================================================

	  `Vores`, `materialenr`, q10( `.` )
	  
	, generic_item( [ line_item_for_buyer, s1 ] )

] ).

%=======================================================================
i_line_rule_cut( line_discount_line, [ 
%=======================================================================

	  `Rabat`, dummy(s1), tab
	  
	, generic_item( [ line_percent_discount, d, `-` ] )

] ).

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
