package com.dwightaspencer.javacv;

import java.lang.System;
import java.lang.Class;
import java.io.File;
import java.io.InputStream;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.io.IOException;
import java.util.jar.JarFile;
import java.util.jar.JarEntry;
import java.util.Vector;
import java.util.Enumeration;
import java.security.CodeSource;
import java.net.URL;
import java.net.URISyntaxException;

class JavaCV {

	private static String OS;
	private static String msg;
	private static CodeSource source;
	
	public boolean isOS(String match) {
		return (this.OS.indexOf(match) >= 0);
	}

	public boolean isExtention(String match) {
		return (this.getJarFilename().indexOf(match) >= 0);
	}


	public boolean isMac() {
		return this.isOS("mac");
	}

	public boolean isLinux() {
		return this.isOS("nux");
	}


	public boolean isWindows() {
		return this.isOS("win");
	}

	public boolean isJar() {
		return this.isExtention(".jar");
	}

	public boolean isPdf() {
		return this.isExtention(".pdf");
	}

	public URL getJarLocation() {
		return this.source.getLocation();
	}

	public String getJarPath() {
		return this.getJarLocation().getPath();
	}

	public String getJarFilename() {
		File f;

		try {
			f = new File(this.getJarLocation().toURI());
		} catch(URISyntaxException err) {
			f = new File(this.getJarLocation().getPath());
		}

		return f.getAbsolutePath();
	}

	public File getSelfPath() {
		return new File(this.getJarPath()).getParentFile();
	}

	public Vector<String> getContents() throws IOException {
		Vector<String> contents = new Vector<String>();

		JarFile file = new JarFile(this.getJarFilename());
		Enumeration<JarEntry> enums = file.entries();

		while(enums.hasMoreElements()) {
			JarEntry entry = enums.nextElement();
			if (entry.getName().startsWith("res"))
				contents.add(entry.getName());
		}

		return contents;
	}

	public void extractFileFromJar(String resource, String destination) throws IOException {
		InputStream inputStream = this.getClass().getResourceAsStream(resource);
		FileOutputStream outputStream = new FileOutputStream(destination);

		while (inputStream.available() > 0)
			outputStream.write(inputStream.read());

		outputStream.flush();
		inputStream.close();
		outputStream.close();

	}

	public JavaCV(String message) {
		this.msg     = message;
		this.source  = JavaCV.class
		                     .getProtectionDomain()
				     .getCodeSource();

		this.OS = System.getProperty("os.name").toLowerCase();
	}


	public static void main(String[] args) throws IOException {

		JavaCV instance = new JavaCV("");
		String plumber  = "";
		Process proc;

		String cookie   = "filegate.txt";

		if (instance.isWindows()) plumber = "cmd.exe /c start ";
		if (instance.isMac())     plumber = "open ";
		if (instance.isLinux())   plumber = "xdg-open ";

		if (instance.isPdf()) {
			instance = new JavaCV(
				"You found a cookie. Now visit github.com/denzuko to see more of my works."
			);

			System.out.println(instance.getJarFilename());
			System.out.println(instance.msg);

			proc = Runtime.getRuntime().exec(plumber + "https://about.me/dwightaspencer");
			System.exit(0);
		}

		if (instance.isJar()) {
			instance = new JavaCV(
				"Brillent! Second cookie found. If this has a go program then it should be extracted and running"
			);
			try {
				Enumeration contents = instance.getContents().elements();

				System.out.println("Contents:");
				System.out.println();

				while(contents.hasMoreElements())
					System.out.println(contents.nextElement());

				instance.extractFileFromJar("/res/"+cookie, cookie);
				proc = Runtime.getRuntime().exec(plumber + cookie);

			} catch(IOException err) {
				err.printStackTrace();
				System.exit(1);
			}

			System.out.println();
			System.out.println(instance.msg);
			System.exit(0);
		}

		System.exit(1);
	}
}
