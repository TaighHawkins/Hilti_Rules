%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - LVD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( lvd_be, `21 July 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	  
	, [q0n(line), get_del_note]
	, get_order_number
	
	, get_order_date

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

	, [q0n(line), get_totals]
	
	, set( delivery_note_ref_no_failure )
	
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

	, [ or([ 
	 [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	   , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`0700`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `10558391` )   ]    %TEST
	    , suppliers_code_for_buyer( `10055296` )                      %PROD
	]) ]
	
	, buyer_registration_number(`BE-ADAPTRI`)
	
	, sender_name( `LVD Company NV` )
	
	, buyer_dept(`BELVD0008942118`)
	, delivery_from_contact(`BELVD0008942118`)
	, delivery_note_reference(`BELVD0010055296`)

	, set( reverse_punctuation_in_numbers )
	
	, set( delivery_note_ref_no_failure )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER Suppliers Code AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================	  
	  
	  q(0,50,line), generic_horizontal_details( [ [ `INKOOPORDER`], 100, order_number, s ] )
	
] ).

%=======================================================================
i_rule( get_order_date, [
%=======================================================================	  
	  
	  q(0,50,line), generic_horizontal_details( [ [ `Datum`, `afgedrukt`, `:` ],50,  invoice_date, date ] )
	  	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_totals, [ 
%=======================================================================

	 `Levering`, `:`, tab, dummy(s), tab, total_net(d), `EUR`, newline
	
	
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
			  
			 , line

		] )

	] )
		
	, line_end_line

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `Pos`, `.`, tab, `Project`, tab, `Omschrijving`, tab, `Aant`, `.`, `Eenh`, `.`, tab, `Prijs`, `/`, `Eenh`, `.`, tab, `Kort`, `.`, `%`, tab, `Totaal`, tab, `Levering`,  newline ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ 
%=======================================================================

	or([
	
		[`Opmerkingen`, tab, `Goederen`, tab, `Korting`,  newline]
		,
		[`Opmerkingen`, tab, `Kosten`,  newline]
		,
		[`Opmerkingen`, tab, `Korting`, tab, `Kosten`,  newline]
		
		])
	
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	
	or([
	
	[line_order_line_number(d), tab, dummy(s), tab, line_quantity(d), `st`, tab, dummy(s), tab, line_net_amount(d), read_ahead(delivery_date(date)), line_original_order_date(date), newline]
	,
	
	[`art`, `.`, `nr`, `.`, `:`, line_item(d), newline]
	,
	
	[`art`, `:`, dummy(d), `-`, newline]
	,
	[line_item(d), newline]
	,
	[append(line_descr(s), ` `,``), newline]
	,
	[append(line_descr(s), ` `,``), tab, append(line_descr(s), ` `,``), newline]
	
	])
	

] ).

