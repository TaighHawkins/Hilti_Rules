%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - HILTI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( hilti_test, `4 December 2014` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_op_param( extract_script_file_name, _, _, _, _, `utils.ps1` ).
i_op_param( extract_script_function_name, _, _, _, _, `bullzip` ).

i_page_split_rule_list( [ set(chain,`unrecognised`), select_buyer ] ).

%=======================================================================
i_rule( select_buyer, [
%=======================================================================

	q0n(line), check_text_identification_line
	
] ).

%=======================================================================
i_line_rule( check_text_identification_line, [
%=======================================================================

	or( [

		[ check_text( `AteaA/S` ), set(chain, `dk atea`), trace([`ATEA ...`]) ]

		, [ check_text( `915771313` ), set(chain, `gb keepmoat regeneration (fhm)`), trace([`KEEPMOAT REGENERATION (FHM) ...`]) ]

	] )
	
] ).