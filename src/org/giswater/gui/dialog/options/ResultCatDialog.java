/*
 * This file is part of Giswater
 * Copyright (C) 2013 Tecnics Associats
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 * 
 * Author:
 *   David Erill <daviderill79@gmail.com>
 */
package org.giswater.gui.dialog.options;

import java.awt.Color;
import java.awt.Font;

import javax.swing.ImageIcon;
import javax.swing.JButton;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTextField;
import javax.swing.SwingConstants;
import javax.swing.border.LineBorder;
import javax.swing.border.TitledBorder;

import net.miginfocom.swing.MigLayout;


public class ResultCatDialog extends AbstractOptionsDialog {

	private static final long serialVersionUID = -6349825417550216902L;
	private JTextField txtQuality;
	private JTextField txtHydraulic;
	private JTextField txtDuration;
	private JTextField txtRule;
	private JTextField txtPattern;
	private JTextField txtReport;
	private JTextField txtReportStart;
	private JTextField txtPatternStart;
	private JTextField txtStart;
	private JButton btnDelete;
	private JTextField textField;
	private JTextField textField_1;
	private JTextField textField_2;
	private JTextField textField_3;
	private JTextField textField_4;
	private JTextField textField_5;
	private JTextField textField_6;
	private JTextField textField_7;
	private JButton btnPrevious;
	private JButton btnNext;
	
	
	public ResultCatDialog() {
		initConfig();
		createComponentMap();
	}
	
	
	private void initConfig(){

		setTitle("Table rpt_result_cat");
		setBounds(0, 0, 468, 391);
		getContentPane().setLayout(new MigLayout("", "[90.00][360.00]", "[301.00][5px:n][30]"));
		
		JPanel panelGeneral = new JPanel();
		panelGeneral.setFont(new Font("Tahoma", Font.BOLD, 14));
		panelGeneral.setBorder(new TitledBorder(new LineBorder(new Color(0, 0, 0)), "GENERAL", TitledBorder.CENTER, TitledBorder.TOP, null, null));
		getContentPane().add(panelGeneral, "cell 0 0 2 1,growy");
		panelGeneral.setLayout(new MigLayout("", "[75.00:n][100:n][10px:10px][100:n][100:120]", "[25px:n][25px:n][25px:n][25px:n][25px:n][25px][25px][25px][25px:n][10px:n]"));

		JLabel lblFlowUnits = new JLabel("Result id:");
		panelGeneral.add(lblFlowUnits, "cell 0 0,alignx trailing");
		
		txtDuration = new JTextField();
		txtDuration.setName("result_id");
		txtDuration.setColumns(10);
		panelGeneral.add(txtDuration, "cell 1 0,growx");
		
		JLabel lblNewLabel_1 = new JLabel("Flow units:");
		panelGeneral.add(lblNewLabel_1, "cell 0 1,alignx trailing");
		
		txtQuality = new JTextField();
		txtQuality.setName("flow_units");
		txtQuality.setColumns(10);
		panelGeneral.add(txtQuality, "cell 1 1,growx");
		
		JLabel lblFlowRouteM = new JLabel("Flow route m:");
		panelGeneral.add(lblFlowRouteM, "cell 3 1,alignx trailing");
		
		txtHydraulic = new JTextField();
		txtHydraulic.setName("flowrout_m");
		txtHydraulic.setColumns(10);
		panelGeneral.add(txtHydraulic, "cell 4 1,growx");
		
		JLabel lblPatternTimestep = new JLabel("Rain runoff:");
		lblPatternTimestep.setHorizontalAlignment(SwingConstants.TRAILING);
		panelGeneral.add(lblPatternTimestep, "cell 0 2,alignx trailing");
		
		txtPattern = new JTextField();
		txtPattern.setName("rain_runof");
		txtPattern.setColumns(10);
		panelGeneral.add(txtPattern, "cell 1 2,growx");
		
		JLabel lblStartDate = new JLabel("Start date:");
		lblStartDate.setHorizontalAlignment(SwingConstants.TRAILING);
		panelGeneral.add(lblStartDate, "cell 3 2,alignx trailing");
		
		txtRule = new JTextField();
		txtRule.setName("start_date");
		txtRule.setColumns(10);
		panelGeneral.add(txtRule, "cell 4 2,growx");
		
		JLabel lblReportTimestep = new JLabel("Snowmelt:");
		lblReportTimestep.setHorizontalAlignment(SwingConstants.TRAILING);
		panelGeneral.add(lblReportTimestep, "cell 0 3,alignx trailing");
		
		txtReport = new JTextField();
		txtReport.setName("snowmelt");
		txtReport.setColumns(10);
		panelGeneral.add(txtReport, "cell 1 3,growx");
		
		JLabel lblPatternStep = new JLabel("End date:");
		lblPatternStep.setHorizontalAlignment(SwingConstants.TRAILING);
		panelGeneral.add(lblPatternStep, "cell 3 3,alignx trailing");
		
		txtPatternStart = new JTextField();
		txtPatternStart.setName("end_date");
		txtPatternStart.setColumns(10);
		panelGeneral.add(txtPatternStart, "cell 4 3,growx");
		
		JLabel lblStartClocktime = new JLabel("Groundwater:");
		lblStartClocktime.setHorizontalAlignment(SwingConstants.TRAILING);
		panelGeneral.add(lblStartClocktime, "cell 0 4,alignx trailing");
		
		txtStart = new JTextField();
		txtStart.setName("groundw");
		txtStart.setColumns(10);
		panelGeneral.add(txtStart, "cell 1 4,growx");
		
		JLabel lblReportStart = new JLabel("Dry days:");
		lblReportStart.setHorizontalAlignment(SwingConstants.TRAILING);
		panelGeneral.add(lblReportStart, "cell 3 4,alignx trailing");
		
		txtReportStart = new JTextField();
		txtReportStart.setName("dry_days");
		txtReportStart.setColumns(10);
		panelGeneral.add(txtReportStart, "cell 4 4,growx");
		
		JLabel lblFlowRouting = new JLabel("Flow routing:");
		lblFlowRouting.setHorizontalAlignment(SwingConstants.TRAILING);
		panelGeneral.add(lblFlowRouting, "cell 0 5,alignx trailing");
		
		textField = new JTextField();
		textField.setName("flow_rout");
		textField.setColumns(10);
		panelGeneral.add(textField, "cell 1 5,growx");
		
		JLabel lblStatistic = new JLabel("Report timestep:");
		panelGeneral.add(lblStatistic, "cell 3 5,alignx trailing");
		
		textField_4 = new JTextField();
		textField_4.setName("rep_tstep");
		textField_4.setColumns(10);
		panelGeneral.add(textField_4, "cell 4 5,growx");
		
		JLabel lblPondAll = new JLabel("Pond all:");
		lblPondAll.setHorizontalAlignment(SwingConstants.TRAILING);
		panelGeneral.add(lblPondAll, "cell 0 6,alignx trailing");
		
		textField_1 = new JTextField();
		textField_1.setName("pond_all");
		textField_1.setColumns(10);
		panelGeneral.add(textField_1, "cell 1 6,growx");
		
		JLabel lblInfiltration = new JLabel("Wet timestep:");
		panelGeneral.add(lblInfiltration, "cell 3 6,alignx trailing");
		
		textField_5 = new JTextField();
		textField_5.setName("wet_tstep");
		textField_5.setColumns(10);
		panelGeneral.add(textField_5, "cell 4 6,growx");
		
		JLabel lblWaterQ = new JLabel("Water q:");
		lblWaterQ.setHorizontalAlignment(SwingConstants.TRAILING);
		panelGeneral.add(lblWaterQ, "cell 0 7,alignx trailing");
		
		textField_2 = new JTextField();
		textField_2.setName("water_q");
		textField_2.setColumns(10);
		panelGeneral.add(textField_2, "cell 1 7,growx");
		
		JLabel lblRuleTimestep = new JLabel("Dry timestep:");
		lblRuleTimestep.setHorizontalAlignment(SwingConstants.TRAILING);
		panelGeneral.add(lblRuleTimestep, "cell 3 7,alignx trailing");
		
		textField_6 = new JTextField();
		textField_6.setName("dry_tstep");
		textField_6.setColumns(10);
		panelGeneral.add(textField_6, "cell 4 7,growx");
		
		JLabel lblInfilM = new JLabel("Infil m:");
		panelGeneral.add(lblInfilM, "cell 0 8,alignx trailing");
		
		textField_3 = new JTextField();
		textField_3.setName("infil_m");
		textField_3.setColumns(10);
		panelGeneral.add(textField_3, "cell 1 8,growx");
		
		JLabel lblRoutTimestep = new JLabel("Rout timestep:");
		lblRoutTimestep.setHorizontalAlignment(SwingConstants.TRAILING);
		panelGeneral.add(lblRoutTimestep, "cell 3 8,alignx trailing");
		
		textField_7 = new JTextField();
		textField_7.setName("rout_tstep");
		textField_7.setColumns(10);
		panelGeneral.add(textField_7, "cell 4 8,growx");
		
		ImageIcon image = new ImageIcon("images/imago.png");        
		super.setIconImage(image.getImage());		
		
		btnPrevious = new JButton("<");
		btnPrevious.setActionCommand("movePrevious");
		getContentPane().add(btnPrevious, "flowx,cell 1 2,alignx right");
		
		btnNext = new JButton(">");
		btnNext.setActionCommand("moveNext");
		getContentPane().add(btnNext, "cell 1 2,alignx right");
		
		btnDelete = new JButton("Delete");
		btnDelete.setActionCommand("delete");
		getContentPane().add(btnDelete, "cell 1 2,alignx right");
		
		setupListeners();
		
	}

	
	protected void setupListeners() {
		btnPrevious.addActionListener(this);
		btnNext.addActionListener(this);		
		btnDelete.addActionListener(this);
	}		
	

}