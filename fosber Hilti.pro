%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - Fosber
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


i_version( fosber, `30 July 2015` ).

i_date_format( _ ).
%i_pdf_parameter( x_tolerance_100, 100 ).

i_correlate_amounts_total_to_use( total_net, net_subtotal_1).
i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1).

%i_user_field( invoice, delivery_charge, `Delivery Charge` ).
%i_user_field( invoice, delivery_district, `Delivery District` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	 get_fixed_variables
	, [q0n(line), get_order_number]
	, get_order_date
	, get_delivery_contact
	, get_delivery_number
	, [q0n(line), get_buyer_contact]
	, [q0n(line), get_delivery_note]
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

	  set( purchase_order )
	  
	, set(reverse_punctuation_in_numbers)
	
	, agent_code_1(`00`)
	, agent_code_2(`01`)
	, agent_code_3(`7500`)
	, buyer_registration_number(`IT-ADAPTRI`)
	
	, buyer_party( `LS` )
	, supplier_party(`LS`)
	, supplier_registration_number(`P11_100`)
	, agent_name(`GBADAPTRIS`)
	
	%, buyers_code_for_buyer(`Subsidiary`)
	
, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `13025411` ) ]    %TEST
	    , suppliers_code_for_buyer( `10055296` )                      %PROD
	]) ]



		

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET BUYER AND DELIVERY CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%=======================================================================
i_line_rule( get_delivery_note, [
%=======================================================================

	
	or([
	
	[`DESTINATION`, tab, `SHIPMENT`, `AS`, `FOLLOWS`, tab, `CARRIAGE`,  newline, delivery_note_reference(`ITFOSBMAGAZZINO`)]
	,
	[`DESTINATION`, q10(tab), append(delivery_note_reference(s), `ITFOSB`, ``),  tab,`SHIPMENT`, `AS`, `FOLLOWS`, tab, `CARRIAGE`,  newline ]
	,
	[`DESTINATION`, tab, `SHIPMENT`, `AS`, `FOLLOWS`, tab, `CARRIAGE`, shipping_instructions(s), newline, delivery_note_reference(`ITFOSBMAGAZZINO`)]
	,
	[`DESTINATION`, q10(tab), append(delivery_note_reference(s), `ITFOSB`, ``),  tab,`SHIPMENT`, `AS`, `FOLLOWS`, tab, `CARRIAGE`, shipping_instructions(s),  newline ]
	
	])
	
] ).


%=======================================================================
i_line_rule( get_buyer_contact, [
%=======================================================================

	
	read_ahead(delivery_contact(s)), buyer_contact(s), tab, `particolari`, `espresse`, `nell`, `'`, `ordine`, `stesso`, `salvo`, `accordi`, `diversi`, `sottoscritto`, `tra`, `le`, `parti`,  newline
	
	
] ).



%======================================================================================================
i_line_rule( get_order_number, [
%======================================================================================================
		 
	dummy(d), tab, order_number(s), tab, invoice_date(date), tab, dummy(d), newline
	
]).





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TOTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%=======================================================================
i_line_rule( get_totals, [
%=======================================================================

	q0n(anything), `EUR`, tab, total_net(d), newline
	, check( total_net = Net )
	
	, total_invoice( Net )
	
	

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
i_line_rule_cut( line_header_line, [
%=======================================================================
	
		`POS`, `.`, tab, `CODE`, tab, `GOOD`, `'`, `S`, `DESCRIPTION`, tab, `DELIVERY`, `DATE`, tab, `U`, `.`, `N`, `.`, tab, `QTY`, tab, `U`, `.`, `PRICE`, tab, `DISC`, `.`, `1`, `DISC2`, tab, `AMOUNT`,  newline
 
		, trace([`found header`])
	
] ).

%=======================================================================
i_line_rule_cut( line_end_line, [ 
%=======================================================================

		
		`CONDIZIONI`, `DI`, `PAGAMENTO`, tab, `TOTALE`,  newline		
	

] ).

%=======================================================================
i_line_rule_cut( line_invoice_rule, [
%=======================================================================

		
		line_order_line_number(d), tab, line_item_for_buyer(d), tab, line_descr(s), q10(tab), line_original_order_date(date), tab, line_quantity_uom_code(w), tab, line_quantity(d), tab, line_unit_amount(d), tab, line_net_amount(d), newline

		
] ).



